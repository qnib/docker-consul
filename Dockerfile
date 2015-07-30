FROM qnib/syslog

RUN yum install -y unzip
# consul
RUN cd /tmp/ && curl -Ls -o /tmp/consul.zip  https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip && \
    unzip /tmp/consul.zip && rm -f /tmp/consul.zip && mv consul /usr/local/bin/
RUN cd /tmp/ && curl -Ls -o /tmp/consul_web_ui.zip http://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip && \
    unzip /tmp/consul_web_ui.zip && rm -f /tmp/consul_web_ui.zip && mv dist /opt/consul-web-ui
ADD etc/consul.json /etc/consul.json
ADD opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh

# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/

