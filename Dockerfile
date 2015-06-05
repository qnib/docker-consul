FROM qnib/supervisor
MAINTAINER "Christian Kniep <christian@qnib.org>"

RUN yum install -y unzip
# syslog
RUN yum install -y syslog-ng nmap
ADD etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
ADD etc/syslog-ng/conf.d/logstash.conf.disabled /etc/syslog-ng/conf.d/
ADD etc/consul.d/check_syslog-ng.json /etc/consul.d/check_syslog-ng.json
ADD opt/qnib/bin/start_syslog-ng.sh /opt/qnib/bin/start_syslog-ng.sh
# consul
ADD https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip /tmp/consul.zip
RUN unzip /tmp/consul.zip && rm -f /tmp/consul.zip
RUN mv consul /usr/local/bin/

ADD http://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip /tmp/consul_web_ui.zip
RUN unzip /tmp/consul_web_ui.zip && rm -f /tmp/consul_web_ui.zip && \
    mv dist /opt/consul-web-ui

ADD etc/consul.json /etc/consul.json
ADD opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh


# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/

