#!/bin/bash

PIDFILE=/var/run/consul.pid
CONSUL_BIN=/usr/local/bin/consul
ADDR=eth0
RUN_SERVER=${RUN_SERVER-auto}

if [ ! -f ${CONSUL_BIN} ];then
   CONSUL_BIN=/usr/bin/consul
fi

# if consul in env, join
LINKED_SERVER=0
for env_line in $(env);do
    if [ $(echo ${env_line} |grep -c CONSUL_SERVER) -ne 0 ];then
        LINKED_SERVER="$(echo ${env_line}|awk -F\= '{print $2}')"
        break
    elif [ $(echo ${env_line} |egrep -c "^CONSU.*_ADDR") -ne 0 ];then
        LINKED_SERVER="$(echo ${env_line}|awk -F\= '{print $2}')"
        break
    elif [ $(echo ${env_line} |grep -c PORT_8500_TCP_ADDR) -ne 0 ];then
        LINKED_SERVER="$(echo ${env_line}|awk -F\= '{print $2}')"
        break
    fi
done
if [ "X${NO_CONSUL}" != "X" ];then
    echo "Do not start any docker server"
    touch ${PIDFILE}
else
    if [ "X${LINKED_SERVER}" == "X$(ip -o -4 address show eth0|awk '{print $4}'|awk -F\/ '{print $1}')" ];then
        LINKED_SERVER=0
    fi
    ## Check if eth0 already exists
    IPv4_RAW=$(ip -o -4 addr show ${ADDR})
    EC=$?
    if [ ${EC} -eq 1 ];then
        echo "## Wait for pipework to attach device 'eth0'"
        pipework --wait
        IPv4_RAW=$(ip -o -4 addr show ${ADDR})
    fi
    IPv4=$(echo ${IPv4_RAW}|egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")
    if [ "X${ADDV_ADDR}" != "X" ];then
        if [ "X${ADDV_ADDR}" == "XSERVER" ];then
            ADDV_ADDR=$(cat /host_info/ip_eth0)
        fi
        sed -i -e "s#\"advertise_addr\":.*#\"advertise_addr\": \"${ADDV_ADDR}\",#" /etc/consul.json
    else
        sed -i -e "s#\"advertise_addr\":.*#\"advertise_addr\": \"${IPv4}\",#" /etc/consul.json
    fi
    if [ "X${DC_NAME}" != "X" ];then
        sed -i -e "s#\"datacenter\":.*#\"datacenter\": \"${DC_NAME}\",#" /etc/consul.json
    fi
    if [ "X${LINKED_SERVER}" != "X0" ];then
        RUN_SERVER=false
        sed -i -e "s#\"start_join\":.*#\"start_join\": [\"${LINKED_SERVER}\"],#" /etc/consul.json
    fi
    
    ## If we should join another server
    JOIN_WAN=""
    if [ "X${WAN_SERVER}" != "X" ];then
        JOIN_WAN="-join-wan=${WAN_SERVER}"
    fi
    
    if [ "X${RUN_SERVER}" == "Xfalse" ];then
        sed -i -e "s#\"server\":.*#\"server\": false,#" /etc/consul.json
        sed -i -e "s#\"bootstrap\":.*#\"bootstrap\": false,#" /etc/consul.json
    fi
    #if [ "X${ENABLE_SYSLOG}" == "Xtrue" ];then
    #    sed -i -e "s#\"enable_syslog\":.*#\"enable_syslog\": true,#" /etc/consul.json
    #fi

    mkdir -p /etc/consul.d
    mkdir -p /var/consul/
    ${CONSUL_BIN} agent -pid-file=${PIDFILE} -config-file=/etc/consul.json -config-dir=/etc/consul.d ${JOIN_WAN} &
fi

sleep 1

trap "kill -9 $(cat ${PIDFILE});rm -f ${PIDFILE}" SIGINT SIGTERM 15 9 10

while [ -f ${PIDFILE} ];do
    sleep 1
done
