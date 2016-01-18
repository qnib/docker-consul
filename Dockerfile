FROM qnib/bats

RUN yum install -y unzip jq bc git-core mercurial build-essential make
# consul
ENV CONSUL_VER=0.6.0 \
    GOVERSION="1.5.3" \
    SRCROOT="/opt/go" \
    SRCPATH="/opt/gopath" \
    ARCH="amd64" \
    GOPATH=/usr/local/ \
    GOROOT=/opt/go
## Install go
RUN curl -sfL https://storage.googleapis.com/golang/go${GOVERSION}.linux-${ARCH}.tar.gz |bsdtar xf - -C /opt/ && \
    ln -s /opt/go/bin/go /usr/local/bin/ && \
    go version
RUN git clone https://github.com/evan2645/consul.git /opt/consul/ && \
    cd /opt/consul/ && \
    git checkout add-wan-address-to-node && \
    make
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
