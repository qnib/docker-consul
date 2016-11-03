FROM qnib/supervisor

RUN dnf install -y unzip jq bc tar bsdtar

# consul
ARG CONSUL_VER=0.7.0
ARG CT_VER=0.16.0

RUN curl -fsL https://releases.hashicorp.com/consul/${CONSUL_VER}/consul_${CONSUL_VER}_linux_amd64.zip |bsdtar xf - -C /usr/local/bin/ \
 && chmod 755 /usr/local/bin/consul \
 && mkdir -p /opt/consul-web-ui \
 && curl -Lsf https://releases.hashicorp.com/consul/${CONSUL_VER}/consul_${CONSUL_VER}_web_ui.zip | bsdtar xf - -C /opt/consul-web-ui \
 # consul-template
 && curl -Lsf https://releases.hashicorp.com/consul-template/${CT_VER}/consul-template_${CT_VER}_linux_amd64.zip | bsdtar xf - -C /usr/local/bin/ \
 && chmod +x /usr/local/bin/consul-template \
 # go-github script
 && wget -qO /usr/local/bin/go-github https://github.com/qnib/go-github/releases/download/0.2.2/go-github_0.2.2_Linux \
 && chmod +x /usr/local/bin/go-github \
 && echo "# consul-content: $(/usr/local/bin/go-github rLatestUrl --ghorg qnib --ghrepo consul-content --regex ".*\.tar" --limit 1)" \
 && curl -fsL $(/usr/local/bin/go-github rLatestUrl --ghorg qnib --ghrepo consul-content --regex ".*\.tar" --limit 1) |tar xf - -C /opt/qnib/ \
 && echo "# $(/usr/local/bin/go-github rLatestUrl --ghorg CiscoCloud --ghrepo consul-cli --regex ".*linux_amd64.tar.gz" --limit 1)" \
 && wget -qO - $(/usr/local/bin/go-github rLatestUrl --ghorg CiscoCloud --ghrepo consul-cli --regex ".*linux_amd64.tar.gz" --limit 1) |tar xfz - -C /tmp/ \
 && mv /tmp/consul-cli_*/consul-cli /usr/local/bin/
# supervisor start-scripts
ADD etc/supervisord.d/ /etc/supervisord.d/
ADD etc/consul.d/agent.json /etc/consul.d/
