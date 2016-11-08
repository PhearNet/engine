# Engine [![Build Status](https://travis-ci.org/PhearNet/engine.png)](https://travis-ci.org/PhearNet/engine)[![Dependency Status](https://www.versioneye.com/user/projects/5665f957f376cc002c000fe0/badge.svg?style=flat)](https://www.versioneye.com/user/projects/5665f957f376cc002c000fe0)

> Nomad + Consul + Swarm as a System

#### Contents:
 * [Getting Started](#Getting-Started)
    * [Basic Requirements](#Getting-Started)
    * [Running the Swarm-Cluster in Nomad](#Getting-Started)
 * [Provisioning Containers](#Provisioning-Containers)
    * [Using Docker-Machine/Compose](#Provisioning-Containers)
    * [Using Nomad](#Provisioning-Containers)
 * [Wiki]() - Comming soon!
     * [Contributing](.github/CONTRIBUTING) - Comming soon!
     * [License](./LICENSE)

### Overview:
This project aims lets you use the best of both Docker Swarm and HashiCorp
Nomad/Consul worlds. Running docker swarm and registrator containers as a 
"nomad system job" results in orchestration of docker swarm on every node. 
in the configured data centers. 

Both services(Nomad/Swarm) support Consul for service discovery. Nomad handles 
registering "nomad jobs" and swarm handles "docker-compose up" for docker-machine 
environments. The docker-compose containers will automagiclly added as services via
the registrator

The nodejs application gathers telemetry as well as syncs public service 
DNS records from Consul to CloudFlare with help from docker registrator, 
statsd, logstash, and node.

## Getting Started
Make sure to have the following installed:
 - [bundle]() 
 - [ruby]()
 - [nodejs]()
 - [vagrant]()
 
Run the swarm:
```shell
npm install
vagrant up
vagrant ssh nomad-1
nomad run run.nomad
exit
```
Navigate to [localhost:8501](http://localhost:8501)

## Provisioning Containers
You can find the current "Swarm Leader IP" in the consul-ui
under [Key/Value -> Docker -> Swarm -> Leader](). You can 
replace <Swarm-Leader-IP> with the ip address found in the kv.

docker-compose/machine:
```shell
eval "$(docker-machine env --swarm <Swarm-Leader-IP>)"
docker-compose up
```

nomad:
```shell
nomad run some.service.nomad -address=<Swarm-Leader-IP>
```

### Features:
[![Throughput Graph](https://graphs.waffle.io/PhearNet/engine/throughput.svg)](https://waffle.io/PhearNet/engine/metrics/throughput)
#### v0.1.0
- [X] Consul Cluster(server/client/UI)
- [X] Nomad Cluster(server/client) with service discovery
- [X] Nomad "[docker-swarm]()/[registrator]()" job as a system
- [X] Puppet 4.X integration
- [ ] Basic Devops(vagrant, packer, test-kitchen, bats)
- [ ] Basic Telemetry(elasticsearch, statsd, collectd?, logstash)
- [ ] Service Sync to CloudFlare