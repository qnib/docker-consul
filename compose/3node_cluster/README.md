# 3 Node Cluster on 3 physical Machines

## Set up machines

To mimic three physical machines I set up three `docker-machines`.

```
$ machine create -d virtualbox dev
$ machine create -d virtualbox dev2
```

Should look like this at the end...

```
$ machine ls|grep virtualbox
mbp              -        virtualbox   Running   tcp://192.168.99.100:2376
dev              -        virtualbox   Running   tcp://192.168.99.101:2376
dev2             -        virtualbox   Running   tcp://192.168.99.102:2376
```

A 3node Consul cluster. All nodes got hardcoded IP addresses in their environment to  
