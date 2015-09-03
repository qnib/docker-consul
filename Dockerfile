FROM qnib/syslog

RUN yum clean all; yum install -y unzip bind-utils bsdtar
# consul
RUN cd /tmp/ && curl -Ls -o /tmp/consul.zip  https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip && \
    unzip /tmp/consul.zip && rm -f /tmp/consul.zip && mv consul /usr/local/bin/
RUN cd /tmp/ && curl -Ls -o /tmp/consul_web_ui.zip http://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip && \
    unzip /tmp/consul_web_ui.zip && rm -f /tmp/consul_web_ui.zip && mv dist /opt/consul-web-ui
# consul-template
RUN yum install -y make golang git-core mercurial && \
    curl -fsL https://github.com/hashicorp/consul-template/archive/master.zip|bsdtar xf - -C /opt/ && \
    cd /opt/consul-template-master/ && \
    GOPATH=/tmp/ make && \
    mv /opt/consul-template-master/bin/consul-template /usr/local/bin/ && \
    rm -rf /opt/consul-template-master && \
    yum remove -y make golang git-core mercurial && \
    yum autoremove -y
# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/
ADD etc/consul.json /etc/consul.json
ADD opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh


