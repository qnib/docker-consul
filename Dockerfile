FROM qnib/supervisor
MAINTAINER "Christian Kniep <christian@qnib.org>"

RUN yum install -y qnib-consul
RUN yum clean all;yum install -y qnib-consul-web-ui

ADD etc/consul.json /etc/consul.json
ADD opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh
ADD etc/supervisord.d/consul.ini /etc/supervisord.d/

