#!/usr/bin/env python

import json
import os


def main():
    with open('nodes.json') as f:
        data = json.load(f)
    nodes_config = data['nodes']

    for node_name in nodes_config:
        ip_addr = nodes_config[node_name]['ip']
        os.system('./pipework docker0 -i eth1 %s %s/16' % (node_name, ip_addr))

if __name__ == '__main__':
    main()
