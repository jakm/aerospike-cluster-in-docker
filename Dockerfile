# REPO: jakm/aerospike-server

FROM aerospike/aerospike-server:latest

ENV DEBIAN_FRONTEND noninteractive

ADD aerospike.conf /etc/aerospike/aerospike.conf
ADD bootstrap.sh /usr/local/sbin/bootstrap.sh

RUN apt-get update && \
    apt-get install -y --force-yes openssh-server sudo wget python python-pip && \

    # Install Aerospike tools
    wget -O /tmp/aerospike-tools.tgz http://www.aerospike.com/download/tools/latest/artifact/debian7 && \
    mkdir /tmp/aerospike-tools && \
    tar xzf /tmp/aerospike-tools.tgz -C /tmp/aerospike-tools --strip-components=1 && \
    sh -c 'cd /tmp/aerospike-tools && ./asinstall' && \

    # Create and configure vagrant user
    useradd --create-home -s /bin/bash vagrant && \

    # Configure SSH access
    mkdir -p /home/vagrant/.ssh && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys && \
    chown -R vagrant: /home/vagrant/.ssh && \
    echo -n 'vagrant:vagrant' | chpasswd && \

    # Enable passwordless sudo for the "vagrant" user
    mkdir -p /etc/sudoers.d && \
    install -b -m 0440 /dev/null /etc/sudoers.d/vagrant && \
    echo 'vagrant ALL=NOPASSWD: ALL' >> /etc/sudoers.d/vagrant && \

    # Clean up
    rm -rf /tmp/* && \
    apt-get clean

EXPOSE 22
