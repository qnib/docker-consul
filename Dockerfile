FROM qnib/supervisor
MAINTAINER "Christian Kniep <christian@qnib.org>"

RUN yum install -y qnib-consul
EXPOSE 8300

ADD etc/supervisord.d/consul.ini /etc/supervisord.d/

