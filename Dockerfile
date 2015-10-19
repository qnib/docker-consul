FROM qnib/syslog:fd22

RUN dnf install -y unzip bind-utils tar bsdtar

# consul
RUN curl -fsL https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip |bsdtar xf - -C /usr/local/bin/ && \
    chmod 755 /usr/local/bin/consul
RUN cd /tmp/ && curl -Ls -o /tmp/consul_web_ui.zip http://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip && \
    unzip /tmp/consul_web_ui.zip && rm -f /tmp/consul_web_ui.zip && mv dist /opt/consul-web-ui
# consul-template
ENV CT_VER 0.11.0
RUN cd /tmp/ && \
    wget -q -O /tmp/consul-template.tar.gz https://github.com/hashicorp/consul-template/releases/download/v${CT_VER}/consul-template_${CT_VER}_linux_amd64.tar.gz && \
    tar xf /tmp/consul-template.tar.gz && mv /tmp/consul-template_${CT_VER}_linux_amd64/consul-template /usr/local/bin/ && \
    rm -rf /tmp/consul-template_${CT_VER}_linux_amd64
# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/
ADD etc/consul.json /etc/consul.json
COPY opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh


