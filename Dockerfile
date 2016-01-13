FROM qnib/bats

RUN yum install -y unzip jq bc make golang git-core mercurial
# consul
ENV CONSUL_VER=0.6.0 \
    GOPATH=/usr/local/
RUN curl -fsL https://github.com/evan2645/consul/archive/add-wan-address-to-node.zip | bsdtar xf - -C /opt/ && \
    cd /opt/consul-add-wan-address-to-node/ && \
    go get -d && \
    go build -o /usr/local/bin/consul
RUN mkdir -p /opt/consul-web-ui && \
    curl -Lsf https://releases.hashicorp.com/consul/${CONSUL_VER}/consul_${CONSUL_VER}_web_ui.zip | bsdtar xf - -C /opt/consul-web-ui
# consul-template
ENV CT_VER 0.11.1
RUN curl -Lsf https://releases.hashicorp.com/consul-template/${CT_VER}/consul-template_${CT_VER}_linux_amd64.zip | bsdtar xf - -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/consul-template
# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/
ADD etc/consul.json /etc/consul.json
ADD opt/qnib/consul/bin/start.sh /opt/qnib/consul/bin/
RUN ln -s /opt/qnib/consul/bin/start.sh /opt/qnib/bin/start_consul.sh

ADD opt/qnib/consul/etc/bash_functions.sh /opt/qnib/consul/etc/
