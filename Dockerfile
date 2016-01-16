FROM qnib/bats

RUN yum install -y bc \
          git-core \
          jq \
          make \
          mercurial \
          unzip \
          zip
# consul
ENV CONSUL_VER=0.6.0 \
    GOPATH=/usr/local/ \
    GOROOT=/opt/go/ \
    ARCH=amd64 \
    GOVERSION=1.5.3

# Istall go 1.5.3
RUN mkdir -p /opt/go && \
    curl -fsL https://storage.googleapis.com/golang/go${GOVERSION}.linux-${ARCH}.tar.gz |bsdtar xf - -C /opt/ && \
    ln -s /opt/go/bin/go /usr/local/bin/go && \
    go version
###########
## I had some download issues, therefore I download the dependecies upfront in little chunks
## -> Should be collapsed or even left to the make command...
RUN git clone https://github.com/evan2645/consul.git /usr/local/src/github.com/hashicorp/consul/ 
RUN go get -d github.com/mitchellh/gox \
              github.com/hashicorp/go-cleanhttp \
              github.com/mitchellh/iochan
RUN go get -d golang.org/x/tools/cmd/stringer 
RUN git clone https://github.com/hashicorp/serf.git /usr/local/src/github.com/hashicorp/serf
RUN go get -d github.com/armon/circbuf
RUN go get -d github.com/armon/go-metrics
RUN go get -d github.com/fsouza/go-dockerclient
RUN go get -d github.com/armon/go-radix
RUN go get -d github.com/hashicorp/go-multierror
RUN go get -d github.com/hashicorp/net-rpc-msgpackrpc
RUN go get -d github.com/hashicorp/go-immutable-radix
RUN go get -d github.com/hashicorp/go-memdb
RUN go get -d github.com/hashicorp/hcl
RUN go get -d github.com/hashicorp/raft
RUN go get -d github.com/hashicorp/raft-boltdb
RUN go get -d github.com/hashicorp/yamux
RUN go get -d github.com/boltdb/bolt
RUN go get -d golang.org/x/tools/cmd/stringer
RUN go get -d github.com/inconshreveable/muxado
RUN go get -d github.com/hashicorp/go-checkpoint
RUN go get -d github.com/hashicorp/scada-client
RUN go get -d github.com/hashicorp/memberlist
RUN go get -d github.com/hashicorp/go-syslog
RUN go get -d github.com/hashicorp/logutils 
RUN go get -d github.com/miekg/dns
RUN go get -d github.com/mitchellh/cli
RUN go get -d github.com/bgentry/speakeasy
RUN go get -d github.com/mitchellh/mapstructure
RUN go get -d github.com/ryanuber/columnize
#RUN go get -d 
RUN go get -d github.com/mattn/go-isatty
RUN git clone https://github.com/DataDog/datadog-go.git /usr/local/src/github.com/DataDog/datadog-go 
RUN cd /usr/local/src/github.com/hashicorp/consul/ && \
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
