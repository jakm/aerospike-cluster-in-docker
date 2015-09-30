#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $(basename $(readlink -f $0)) ip-address" > /dev/stderr
    exit 1
fi

service ssh start || exit 1

echo "Waiting for interface eth1"

eth1_found=0
for i in $(seq 1 12); do
    if ip addr list dev eth1 > /dev/null 2>&1; then
        eth1_found=1
        break
    fi
    sleep 5
done

if [ "$eth1_found" -ne 1 ]; then
    echo "Interface eth1 doesn't exist" > /dev/stderr
    exit 1
fi

address="$1"
echo "Setting ${address} to aerospike.conf"
sed -i "s/%address%/${address}/g" /etc/aerospike/aerospike.conf || exit 1

echo "Reconfiguring /etc/hosts"
echo "" | tee --append /etc/hosts 2> /dev/null && \
echo "172.17.10.11  aero1" | tee --append /etc/hosts 2> /dev/null && \
echo "172.17.10.12  aero2" | tee --append /etc/hosts 2> /dev/null && \
echo "172.17.10.13  aero3" | tee --append /etc/hosts 2> /dev/null && \
echo "172.17.10.14  aero4" | tee --append /etc/hosts 2> /dev/null && \
echo "172.17.10.15  aero5" | tee --append /etc/hosts 2> /dev/null || exit 1

service aerospike start || exit $?

stop_container() {
    service aerospike stop
    service ssh stop

    exit 0
}

trap stop_container INT

sleep inf

stop_container
