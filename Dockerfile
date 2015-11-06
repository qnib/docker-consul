FROM qnib/syslog

ENV BOOTSTRAP_CONSUL=false \
    RUN_SERVER=false
RUN echo "2015-10-19.1"; yum clean all; yum install -y unzip bsdtar #bind-utils

# consul
RUN curl -fsL https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip |bsdtar xf - -C /usr/local/bin/ && \
    chmod 755 /usr/local/bin/consul
RUN curl -Lsf http://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip | bsdtar xf - -C /opt/ && \
    mv /opt/dist /opt/consul-web-ui
# consul-template
ENV CT_VER 0.11.1
RUN curl -Lsf https://releases.hashicorp.com/consul-template/${CT_VER}/consul-template_${CT_VER}_linux_amd64.zip | bsdtar xf - -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/consul-template
# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/
ADD etc/consul.json /etc/consul.json
ADD opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh


ADD opt/qnib/consul/etc/bash_functions.sh /opt/qnib/consul/etc/
