FROM qnib/syslog

RUN yum install -y unzip
# consul
RUN cd /tmp/ && curl -Ls -o /tmp/consul.zip  https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip && \
    unzip /tmp/consul.zip && rm -f /tmp/consul.zip && mv consul /usr/local/bin/
RUN cd /tmp/ && curl -Ls -o /tmp/consul_web_ui.zip http://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip && \
    unzip /tmp/consul_web_ui.zip && rm -f /tmp/consul_web_ui.zip && mv dist /opt/consul-web-ui
ADD etc/consul.json /etc/consul.json
ADD opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh

# consul-template
ENV CT_VER 0.10.0
WORKDIR /tmp/
RUN wget -q -O /tmp/consul-template.tar.gz https://github.com/hashicorp/consul-template/releases/download/v${CT_VER}/consul-template_${CT_VER}_linux_amd64.tar.gz && \
    tar xf /tmp/consul-template.tar.gz && mv /tmp/consul-template_${CT_VER}_linux_amd64/consul-template /usr/local/bin/ && \
    rm -rf /tmp/consul-template_${CT_VER}_linux_amd64
# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/

