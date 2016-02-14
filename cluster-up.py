#!/usr/bin/env python
# -*- coding: utf8 -*-

from __future__ import absolute_import, division, print_function

import json
import os.path
import subprocess
import sys
import signal


def signal_handler(signo, stack_frame):
    if signo == signal.SIGINT:
        print('SIGINT received')
    elif signo == signal.SIGTERM:
        print('SIGTERM received')
    elif signo == signal.SIGQUIT:
        print('SIGQUIT received')
    else:
        print('Signal', signo, 'received')


def main():

    cwd = os.path.realpath(os.path.dirname(sys.argv[0]))
    os.chdir(cwd)

    with open('nodes.json') as fp:
        config = json.load(fp)

    try:
        net_cmd = 'docker network create --subnet {subnet} --gateway {gateway} {name}'.format(**config['network'])
        subprocess.check_call(net_cmd, shell=True)

        run_cmd_pattern = ('docker run --detach --name {container_name} --memory {memory} '
                           '--net {network_name} --ip {ip_address} '
                           '--volume {config_dir}:/opt/aerospike/etc:ro --volume {data_dir}:/opt/aerospike/data:rw '
                           '{image} asd --foreground --config-file /opt/aerospike/etc/aerospike.conf')

        for name, node_cfg in config['nodes'].iteritems():
            config_dir = node_cfg['config_dir']
            if not config_dir.startswith('/'):
                config_dir = os.path.join(cwd, config_dir)

            data_dir = node_cfg['data_dir']
            if not data_dir.startswith('/'):
                data_dir = os.path.join(cwd, data_dir)

            run_cmd = run_cmd_pattern.format(container_name=name,
                                             memory=node_cfg['memory'],
                                             network_name=config['network']['name'],
                                             ip_address=node_cfg['ip'],
                                             config_dir=config_dir,
                                             data_dir=data_dir,
                                             image=node_cfg['image'])

            subprocess.check_call(run_cmd, shell=True)

        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGQUIT, signal_handler)

        signal.pause()

    except Exception:
        import traceback
        traceback.print_exc()
    finally:
        for name in config['nodes']:
            subprocess.Popen(['docker', 'stop', name]).wait()
            subprocess.Popen(['docker', 'rm', '-f', name]).wait()

        subprocess.Popen(['docker', 'network', 'rm', config['network']['name']]).wait()


if __name__ == '__main__':
    main()
