FROM qnib/supervisor
MAINTAINER "Christian Kniep <christian@qnib.org>"

RUN yum install -y qnib-consul
RUN yum clean all;yum install -y qnib-consul-web-ui

ADD etc/consul_server.json /etc/consul_server.json
ADD etc/consul_client.json /etc/consul_client.json

ADD etc/supervisord.d/consul.ini /etc/supervisord.d/
ADD opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh
ADD opt/qnib/bin/kill_consul.sh /opt/qnib/bin/

