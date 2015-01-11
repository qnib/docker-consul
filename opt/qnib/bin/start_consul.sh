#!/bin/bash

PIDFILE=/var/run/consul.pid

# if consul in env, join
JOIN=""
if [ "X${CONSUL_PORT_8300_TCP_ADDR}" != "X" ];then
   JOIN="-join=${CONSUL_PORT_8300_TCP_ADDR}"
fi

## Check if eth0 already exists
ADDR=eth1
ip addr show ${ADDR} > /dev/null
EC=$?
if [ ${EC} -eq 1 ];then
    echo "## Wait for pipework to attach device 'eth1'"
    pipework --wait
fi

trap "{ kill $(cat ${PIDFILE}) }" SIGINT SIGTERM

mkdir -p /etc/consul.d
mkdir -p /var/consul/

/usr/bin/consul agent -pid-file=${PIDFILE} -server -data-dir /var/consul/ -config-dir=/etc/consul.d/ \
                      ${JOIN} -bootstrap-expect 1 -ui-dir /opt/consul-web-ui/ -client=0.0.0.0
