#!/bin/bash

PIDFILE=/var/run/consul.pid
CONSUL_BIN=/usr/local/bin/consul
ADDR=eth0

if [ ! -d ${CONSUL_BIN} ];then
   CONSUL_BIN=/usr/bin/consul
fi

# if consul in env, join
LINKED_SERVER=0
for env_line in $(env);do
    if [ $(echo ${env_line} |grep -c CONSUL_SERVER) -ne 0 ];then
        LINKED_SERVER="$(echo ${env_line}|awk -F\= '{print $2}')"
        break
    elif [ $(echo ${env_line} |grep -c PORT_8500_TCP_ADDR) -ne 0 ];then
        LINKED_SERVER="$(echo ${env_line}|awk -F\= '{print $2}')"
        break
    fi
done
if [ "X${LINKED_SERVER}" == "X$(ip -o -4 address show eth0|awk '{print $4}'|awk -F\/ '{print $1}')" ];then
    LINKED_SERVER=0
fi
if [ "X${DC_NAME}" != "X" ];then
    sed -i -e "s#\"datacenter\":.*#\"datacenter\": \"${DC_NAME}\",#" /etc/consul.json
fi
if [ "X${LINKED_SERVER}" != "X0" ];then
    sed -i -e "s#\"server\":.*#\"server\": false,#" /etc/consul.json
    sed -i -e "s#\"bootstrap\":.*#\"bootstrap\": false,#" /etc/consul.json
    sed -i -e "s#\"start_join\":.*#\"start_join\": [\"${LINKED_SERVER}\"],#" /etc/consul.json
fi
## Check if eth0 already exists
ip addr show ${ADDR} > /dev/null
EC=$?
if [ ${EC} -eq 1 ];then
    echo "## Wait for pipework to attach device 'eth0'"
    pipework --wait
fi


mkdir -p /etc/consul.d
mkdir -p /var/consul/
${CONSUL_BIN} agent -pid-file=${PIDFILE} -config-file=/etc/consul.json -config-dir=/etc/consul.d &

sleep 1

trap "kill -9 $(cat ${PIDFILE})" SIGINT SIGTERM 15 9 10

while [ -f ${PIDFILE} ];do
    sleep 1
done
