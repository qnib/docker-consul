#!/bin/bash

PIDFILE=/var/run/consul.pid

# if consul in env, join
JOIN=""
for env_line in $(env);do
   if [ $(echo ${env_line} |grep -c PORT_8500_TCP_ADDR) -ne 0 ];then
      JOIN="-join=$(echo ${env_line}|awk -F\= '{print $2}')"
      break
   fi
done

## Check if eth0 already exists
ADDR=eth0
ip addr show ${ADDR} > /dev/null
EC=$?
if [ ${EC} -eq 1 ];then
    echo "## Wait for pipework to attach device 'eth0'"
    pipework --wait
fi

trap "/opt/qnib/bin/kill_consul.sh" SIGINT SIGTERM 15 9 10

mkdir -p /etc/consul.d
mkdir -p /var/consul/

if [ "X${JOIN}" != "X" ];then
    # join someone - therefore a client
    /usr/bin/consul agent -pid-file=${PIDFILE} -data-dir /var/consul/ -config-dir=/etc/consul.d/ ${JOIN} &
else
    # server mode
    /usr/bin/consul agent -pid-file=${PIDFILE} -server -data-dir /var/consul/ -config-dir=/etc/consul.d/ \
    -bootstrap-expect 1 -ui-dir /opt/consul-web-ui/ -client=0.0.0.0 &
fi

while [ -f ${PIDFILE} ];do
    sleep 1
done
