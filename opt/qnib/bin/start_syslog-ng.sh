#!/bin/bash

if [ "X${ENABLE_SYSLOG}" == "Xtrue" ];then
   ln -s /etc/syslog-ng/conf.d/logstash.conf.disabled /etc/syslog-ng/conf.d/logstash.conf  
fi

/usr/sbin/syslog-ng --foreground
