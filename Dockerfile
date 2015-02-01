FROM qnib/supervisor
MAINTAINER "Christian Kniep <christian@qnib.org>"

RUN yum install -y qnib-consul
RUN yum clean all;yum install -y qnib-consul-web-ui

ADD etc/consul.json /etc/consul.json
ADD opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh

# syslog
RUN yum install -y syslog-ng
ADD etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
ADD etc/syslog-ng/conf.d/logstash.conf.disabled /etc/syslog-ng/conf.d/
ADD etc/consul.d/check_syslog-ng.json /etc/consul.d/check_syslog-ng.json
ADD opt/qnib/bin/start_syslog-ng.sh /opt/qnib/bin/start_syslog-ng.sh

# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/

