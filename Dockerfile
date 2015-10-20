FROM qnib/syslog

RUN echo "2015-10-19.1"; yum clean all; yum install -y unzip bsdtar #bind-utils
# consul
RUN cd /tmp/ && curl -Ls -o /tmp/consul.zip  https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip && \
    unzip /tmp/consul.zip && rm -f /tmp/consul.zip && mv consul /usr/local/bin/
RUN cd /tmp/ && curl -Ls -o /tmp/consul_web_ui.zip http://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip && \
    unzip /tmp/consul_web_ui.zip && rm -f /tmp/consul_web_ui.zip && mv dist /opt/consul-web-ui
# consul-template
ENV CT_VER 0.11.0
RUN cd /tmp/ && \
    curl -Lsf https://github.com/hashicorp/consul-template/releases/download/v${CT_VER}/consul-template_${CT_VER}_linux_amd64.zip |bsdtar xf - -C /tmp/ && \
    chmod +x /tmp/consul-template
    
# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/
ADD etc/consul.json /etc/consul.json
ADD opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh


