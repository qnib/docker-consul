#!/bin/bash

PIDFILE=/var/run/consul.pid
CONSUL_BIN=/usr/local/bin/consul
NET_DEV=${CONSUL_NET_DEV-eth0}
RUN_SERVER=${RUN_SERVER-false}
LINKED_SERVER=${LINKED_SERVER-0}
BOOTSTRAP_CONSUL=${BOOTSTRAP_CONSUL-false}
CONSUL_BOOTSTRAP_SOLO=${CONSUL_BOOTSTRAP_SOLO-$BOOTSTRAP_CONSUL}
CONSUL_CLUSTER_IPS=${CONSUL_CLUSTER_IPS-$LINKDED_SERVER}
WAN_SERVER=${WAN_SERVER}
CONSUL_DOMAIN_MATCH=${CONSUL_DOMAIN_MATCH-false}
CONSUL_TRANSLATE_WAN=false

IPv4_RAW=$(ip -o -4 addr show ${NET_DEV})
EC=$?
if [ ${EC} -eq 1 ];then
    echo "## Wait for pipework to attach device 'eth0'"
    pipework --wait
    IPv4_RAW=$(ip -o -4 addr show ${NET_DEV})
fi
IPv4=$(echo ${IPv4_RAW}|egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"|head -n1)

### Set bind address
CONSUL_BIND_ADDR=${IPv4}
sed -i -e "s#\"bind_addr\":.*#\"bind_addr\": \"${CONSUL_BIND_ADDR}\",#" /etc/consul.json

if [ "X${ADDV_ADDR}" == "XSERVER" ];then
    ADDV_ADDR=$(cat /host_info/ip_eth0)
else
    ADDV_ADDR=${IPv4}
fi
if [ "X${CONSUL_ADDV_ADDR_WAN}" == "X" ];then
    CONSUL_ADDV_ADDR_WAN=${ADDV_ADDR}   
fi
if [ ! -f ${CONSUL_BIN} ];then
   CONSUL_BIN=/usr/bin/consul
fi

if [ "X${CONSUL_NODE_NAME}" == "X" ];then
    NODE_NAME=$(hostname -f)
else
    NODE_NAME=${CONSUL_NODE_NAME}
fi

if [ "X${CONSUL_DOMAIN_SUFFIX}" == "X" ] && [ $(echo ${NODE_NAME} | tr '.' '\n' | wc -l) -gt 2 ];then
    CONSUL_DOMAIN_SUFFIX=$(echo ${NODE_NAME} | cut -d "." -f2-)
fi 

if [ "X${NO_CONSUL}" != "X" ];then
    echo "Do not start any consul server"
    touch ${PIDFILE}
    exit 0
fi

sed -i -e "s#\"node_name\":.*#\"node_name\": \"${NODE_NAME}\",#" /etc/consul.json

if [ "x${FORWARD_TO_LOGSTASH}" == "xtrue" ];then
    sed -i '' -e 's/^stdout_events_enabled.*/stdout_events_enabled = true/' /etc/supervisord.d/consul.ini
    sed -i '' -e 's/^stderr_events_enabled.*/stderr_events_enabled = true/' /etc/supervisord.d/consul.ini
    sed -i '' -e 's/^redirect_stderr.*/redirect_stderr = false/' /etc/supervisord.d/consul.ini
fi
# if consul in env, join
for env_line in $(env);do
    if [ $(echo ${env_line} |grep -c CONSUL_SERVER) -ne 0 ];then
        CONSUL_CLUSTER_IPS="$(echo ${env_line}|awk -F\= '{print $2}')"
        break
    elif [ $(echo ${env_line} |egrep -c "^CONSU.*_ADDR=") -ne 0 ];then
        CONSUL_CLUSTER_IPS="$(echo ${env_line}|awk -F\= '{print $2}')"
        break
    elif [ $(echo ${env_line} |grep -c PORT_8500_TCP_ADDR) -ne 0 ];then
        CONSUL_CLUSTER_IPS="$(echo ${env_line}|awk -F\= '{print $2}')"
        break
    fi
done

## Set addvertised address (within DC)
sed -i -e "s#\"advertise_addr\":.*#\"advertise_addr\": \"${ADDV_ADDR}\",#" /etc/consul.json
### set addvertise address wan (if accessed from the outside
sed -i -e "s#\"advertise_addr_wan\":.*#\"advertise_addr_wan\": \"${CONSUL_ADDV_ADDR_WAN}\",#" /etc/consul.json
## Should the consul DNS translation use the internal or the wan address?
if [ "X${CONSUL_TRANSLATE_WAN}" == "Xtrue" ];then
    sed -i -e "s#\"translate_wan_addrs\":.*#\"translate_wan_addrs\": true,#" /etc/consul.json
fi
if [ "X${DC_NAME}" != "X" ];then
    sed -i -e "s#\"datacenter\":.*#\"datacenter\": \"${DC_NAME}\",#" /etc/consul.json
fi
if [ ! -z "${CONSUL_CLUSTER_IPS}" ];then
    START_JOIN=""
    for IP in $(echo ${CONSUL_CLUSTER_IPS} | sed -e 's/,/ /g');do
       if [ "${MY_IP}" != "X${IP}" ] && [ "${NODE_NAME}" != "X${IP}" ];then
          if [ ${CONSUL_DOMAIN_MATCH} == true ] && [ $(echo ${IP} | grep -c ${CONSUL_DOMAIN_SUFFIX}) -ne 1 ];then
              echo "Kick out '${IP}', since it does not match the CONSUL_DOMAIN_SUFFIX '${CONSUL_DOMAIN_SUFFIX}'"
              continue
          elif [ "X${CONSUL_CLUSTER_SKIP_TEST}" == "Xtrue" ];then
              START_JOIN+=" ${IP}"
          elif [ $(curl --connect-timeout 2 -sI ${IP}:8500/ui/|grep -c "HTTP/1.1 200 OK") -eq 1 ];then
              START_JOIN+=" ${IP}"
          fi
       fi
    done
    START_JOIN=$(echo ${START_JOIN}|sed -e 's/ /\",\"/g')
    if [ "X${START_JOIN}" == "X" ] && [ "X${CONSUL_BOOTSTRAP_SOLO}" != "Xtrue" ];then
        echo "Could not find any CLUSTER IP '${CONSUL_CLUSTER_IPS}' and CONSUL_BOOTSTRAP_SOLO!=true"
        exit 1
    elif [ "X${START_JOIN}" == "X" ] && [ "X${CONSUL_BOOTSTRAP_SOLO}" == "Xtrue" ];then
        BOOTSTRAP_CONSUL=true
    else
        sed -i -e "s#\"start_join\":.*#\"start_join\": [\"${START_JOIN}\"],#" /etc/consul.json
    fi
fi

## If we should join another server
JOIN_WAN=""
if [ "X${WAN_SERVER}" != "X" ];then
    JOIN_WAN="-join-wan=${WAN_SERVER}"
fi

if [ "X${BOOTSTRAP_CONSUL}" == "Xtrue" ];then
    sed -i -e "s#\"bootstrap\":.*#\"bootstrap\": true,#" /etc/consul.json
    RUN_SERVER=true
elif [ "X${CONSUL_BOOTSTRAP}" == "Xtrue" ];then
    sed -i -e "s#\"bootstrap\":.*#\"bootstrap\": true,#" /etc/consul.json
    RUN_SERVER=true
elif [ "X${CONSUL_BOOTSTRAP_EXPECT}" != "X" ];then
    sed -i -e "s#\"bootstrap\":.*#\"bootstrap_expect\": ${CONSUL_BOOTSTRAP_EXPECT},#" /etc/consul.json
    RUN_SERVER=true
fi
if [ "X${RUN_SERVER}" == "Xtrue" ];then
    sed -i -e "s#\"server\":.*#\"server\": true,#" /etc/consul.json
fi
if [ "X${DNS_RECURSOR}" != "X" ];then
    sed -i -e "s#\"recursor\":.*#\"recursor\": \"${DNS_RECURSOR}\",#" /etc/consul.json
fi

mkdir -p /etc/consul.d/
mkdir -p /var/consul/
${CONSUL_BIN} agent -pid-file=${PIDFILE} -config-file=/etc/consul.json -config-dir=/etc/consul.d ${JOIN_WAN} &

sleep 1

trap "kill -9 $(cat ${PIDFILE});rm -f ${PIDFILE}" SIGINT SIGTERM 15 9 10

while [ -f ${PIDFILE} ];do
    sleep 1
done
