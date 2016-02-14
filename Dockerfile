FROM qnib/bats

RUN dnf install -y unzip jq bc tar

# consul
ENV CONSUL_VER=0.6.3 \
    CONSUL_CLI_VER=0.1.0 \
    CT_VER=0.12.1
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
ADD etc/consul.json /etc/consul.json
ADD opt/qnib/consul/bin/start.sh /opt/qnib/consul/bin/
RUN ln -s /opt/qnib/consul/bin/start.sh /opt/qnib/bin/start_consul.sh

ADD opt/qnib/consul/etc/bash_functions.sh /opt/qnib/consul/etc/
