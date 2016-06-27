FROM qnib/supervisor

RUN dnf install -y unzip jq bc tar bsdtar nmap curl

# consul
ENV CONSUL_VER=0.6.4 \
    CONSUL_CLI_VER=0.3.0 \
    CT_VER=0.15.0 \
    QNIB_CONSUL=0.1.3.2
RUN curl -fsL https://releases.hashicorp.com/consul/${CONSUL_VER}/consul_${CONSUL_VER}_linux_amd64.zip |bsdtar xf - -C /usr/local/bin/ && \
    chmod 755 /usr/local/bin/consul
RUN mkdir -p /opt/consul-web-ui && \
    curl -Lsf https://releases.hashicorp.com/consul/${CONSUL_VER}/consul_${CONSUL_VER}_web_ui.zip | bsdtar xf - -C /opt/consul-web-ui
# consul-template
RUN curl -Lsf https://releases.hashicorp.com/consul-template/${CT_VER}/consul-template_${CT_VER}_linux_amd64.zip | bsdtar xf - -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/consul-template
# consul-cli
RUN curl -fsL https://github.com/CiscoCloud/consul-cli/releases/download/v${CONSUL_CLI_VER}/consul-cli_${CONSUL_CLI_VER}_linux_amd64.tar.gz|tar xzf - -C /tmp/ && \
    mv /tmp/consul-cli_${CONSUL_CLI_VER}_linux_amd64/consul-cli /usr/local/bin/ && \
    rm -rf /tmp/consul-cli_${CONSUL_CLI_VER}_linux_amd64
# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/
ADD etc/consul.d/agent.json /etc/consul.d/
RUN curl -fsL https://github.com/qnib/consul-content/releases/download/${QNIB_CONSUL}/consul.tar |tar xf - -C /opt/qnib/
HEALTHCHECK --interval=15s --timeout=5s CMD /opt/qnib/consul/bin/check.sh

