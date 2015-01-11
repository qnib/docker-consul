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

trap "/opt/qnib/bin/kill_consul.sh" SIGINT SIGTERM 15 9 10

mkdir -p /etc/consul.d
mkdir -p /var/consul/

if [ "X${JOIN}" != "X" ];then
    /usr/bin/consul agent -pid-file=${PIDFILE} -config-file=/etc/consul_client.json -config-dir=/etc/consul.d/ ${JOIN} &
else
    /usr/bin/consul agent -pid-file=${PIDFILE} -config-file=/etc/consul_server.json -config-dir=/etc/consul.d/ &
fi

while [ -f ${PIDFILE} ];do
    sleep 1
done
