FROM qnib/syslog:fd22

RUN dnf install -y unzip bind-utils tar bsdtar jq

# consul
RUN curl -fsL https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip |bsdtar xf - -C /usr/local/bin/ && \
    chmod 755 /usr/local/bin/consul
RUN curl -Lsf http://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip | bsdtar xf - -C /opt/ && \
    mv /opt/dist /opt/consul-web-ui
# consul-template
ENV CT_VER 0.11.0
RUN curl -Lsf https://github.com/hashicorp/consul-template/releases/download/v${CT_VER}/consul_template_${CT_VER}_linux_amd64.zip |bsdtar xf - -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/consul-template
# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/
ADD etc/consul.json /etc/consul.json
ADD opt/qnib/consul/etc/bash_functions.sh /opt/qnib/consul/etc/
COPY opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh


