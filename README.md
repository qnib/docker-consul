# docker-consul

Image to hold the consul master.

## RUN

It will provide a basic consul server which could be joined.
The Image provides (not yet) the WebUI and exposes the PORT that can be fetched by '--link'ing the container to others.

```
$ docker run -d --name consul -h consul qnib/consul
```
