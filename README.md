# docker-consul

Image to hold the consul master.

## RUN

It will provide a basic consul server which could be joined.
The Image provides (not yet) the WebUI and exposes the PORT that can be fetched by '--link'ing the container to others.

```
$ docker run -d --name consul -h consul qnib/consul
```

The default configuration looks like this:
```
{
    "bootstrap": true,                  # fresh start
    "server": true,                     # enable server mode -> RUN_SERVER=false
    "datacenter": "qnib",               # set DC name -> DC_NAME=dc1
    "data_dir": "/var/consul",
    "log_level": "INFO",
    "enable_syslog": false,
    "ui_dir": "/opt/consul-web-ui/",
    "client_addr": "0.0.0.0",
    "start_join": [],                   # CONSUL_SERVER=<IP> / --links <CONTAINER>:consul
    "advertise_addr": "",               # ADDV_ADDR=<IP>
    "recursor": "8.8.8.8",
    "ports": {
        "dns": 53
    }

}
```
### Control consul agent

The behavior of the agent is controlable through environment variables or linked containers.

- **Join server**

To join a consul server running within a dedicated container the container has to be linked:```--link CONTAINER_NAME:consul```
This should provide the environment variable ```PORT_8500_TCP_ADDR``` (exposed port 8500). 

A plain way of joining a server running on a specific IP address is achieved by providing the address via ```CONSUL_SERVER```.

- 
