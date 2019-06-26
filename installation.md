# OpenShift sandbox

## main goal

Create a sandbox running OpenShift version 3.11 (last version of the 3.XX releases).

keywords: OpenShift 3.11, VirtualBox, CentOS 7 1810, Bare Metal Server

## installation sandbox

> OpenShift is intimately linked with RedHat products like RedHat RHEL7 (enterprise grade product) or CentOS7 (OpenSource version of RHEL7);
> Using other distribution is not supported by this document and will not work as expected;
> Some software dependencies last version are not supported by OpenShift like Docker where only version 1.13.1 is supported.

This tutorial used a VirtualBox instance to understand how to setup OpenShift on a full system installation. Hopefully it is possible to reproduce it on a real bare metal server.
Using a bare metal server will need a real dns name to make it accessible from the web (not covered by this documentation).

**What will be installed ?**

The version of OpenShift 3.11 under a virtual machine.

**Why not install version 4.0 of OpenShift ?**

Version 4.0 does not rely on Ansible anymore. A script is provided to install OpenShift on *AWS* or *Azure* only (not Bare Metal Server).
Installing it on AWS create several EC2 instances: one master, two nodes and a worker. So by the new architecture introduced by the 4.XX releases more than 1 server is needed.

This documentation is about installing a full OpenShift instance in one server.

## Infrastructure

Internet connection is mandatory

The guest (aka virtual machine) use enp0s3 as internal network with this IP assigned `192.168.56.101`

## Prerequisites

- VirtualBox installed
- CentOS-7-x86_64-Minimal-1810.iso Image
- an active internet connection

> ## References
> [virtualbox-host-only-with-internet](https://unix.stackexchange.com/questions/383791/virtualbox-host-only-with-internet)
> [OpenShift installation sources](https://github.com/gshipley/installcentos/)
> [OpenShift installation part1](https://www.youtube.com/watch?v=ZkFIozGY0IA)
> [OpenShift installation part2](https://www.youtube.com/watch?v=S7HoJ09oYn0)

## VirtualBox

> We will use a "host-only" interface to ensure that the virtual machine will use here own static network.
> Host will be set up to allow the virtual machine to access internet (not the case by default)

### Network Configuration

![host network vboxnet0 interface](/virtualbox_setup/host_network_vboxnet0_interface.png)

![host network vboxnet0 server_dhcp](/virtualbox_setup/host_network_vboxnet0_server_dhcp.png)

### Virtual Machine

> (from host) ssh root@IP
> yum install vim, telnet

#### Characteristics

1. **Hard drive** 80Go
1. **CPU** 2
1. **Memory** at least 4096Mo

#### Network

![virtualBox_interface_1](/virtualbox_setup/virtualBox_interface_1.png)

vi /etc/sysconfig/network-scripts/ifcfg-enp0s3

> copy content of provided **ifcfg-enp0s3** file

systemctl restart network.service

### Host (on arch linux as root)

cp /etc/iptables/empty.rules /etc/iptables/iptables.rules

systemctl enable iptables.service

systemctl start iptables.service

sysctl -w net.ipv4.ip_forward=1

printf "net.ipv4.ip_forward=1\n" >> /etc/sysctl.d/30-ipforward.conf

iptables -t filter -I FORWARD --in-interface vboxnet0 --out-interface wlo1 --source 192.168.56.0/24 -j ACCEPT
> in my case the interface connected with internet is my wifi (wlo1)
> use `ip route|grep default` to find your interface connected with internet

iptables -t filter -I FORWARD --in-interface wlo1 --out-interface vboxnet0 --destination 192.168.56.0/24 -j ACCEPT
> in my case the interface connected with internet is my wifi (wlo1)
> use `ip route|grep default` to find your interface connected with internet

iptables -t nat -I POSTROUTING -o wlo1 -j MASQUERADE
> in my case the interface connected with internet is my wifi (wlo1)
> use `ip route|grep default` to find your interface connected with internet

iptables-save > /etc/iptables/iptables.rules

systemctl restart iptables.service

systemctl enable dnsmasq.service

systemctl start dnsmasq.service

> #### now doing a `ping 8.8.8.8` from the Virtual Machine should return
> PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
> 64 bytes from 8.8.8.8: icmp_seq=1 ttl=53 time=25.3 ms

 We need to translate domain and sub-domain addresses represented as **sub-domain.10.0.0.11** to the virtual machine running OpenShift IP address **10.0.0.11**
echo "192.168.56.101  console.192.168.56.101       console.192.168.56.101" >> /etc/hosts
echo "192.168.56.101  console.apps.192.168.56.101  console.apps.192.168.56.101" >> /etc/hosts
echo "192.168.56.101  prometheus-k8s-openshift-monitoring.apps.192.168.56.101 prometheus-k8s-openshift-monitoring.apps.192.168.56.101" >> /etc/hosts
echo "192.168.56.101  alertmanager-main-openshift-monitoring.apps.192.168.56.101 alertmanager-main-openshift-monitoring.apps.192.168.56.101" >> /etc/hosts
echo "192.168.56.101  grafana-openshift-monitoring.apps.192.168.56.101 grafana-openshift-monitoring.apps.192.168.56.101" >> /etc/hosts
> Keep in mind that the dns entries in the host must be updated when exposing a new application route from the virtual machine running OpenShift.
> With 5gb of ram I could not install logging feature. So maybe you should add another entries in your hosts corresponding to logging web interfaces.

#### Additional Information

The script `install-openshift.sh` used to install OpenShift will check the memory available to install or not some features.

So, to install metric feature you will need at least 4Gb of memory, to install the logging feature you will need at least 16gb of memory.

You can have a look to the content of `install-openshift.sh` to understand how OpenShift is setting up.

Running the interactive mode will generate 200 persistent volumes of 500Gb each in the cluster.

> Check that OpenShift is running from the virtual machine by using this command **curl -k https://console.apps.10.0.0.11/**.

> OpenShift config files are located here **/etc/origin/**. It may be useful to see the content of **master-config.yaml**.

> To show network address ip: **ip address show**.

> Get router ip: **curl -s ipinfo.io/ip**.

> You can ping 10.0.0.10 and 10.0.0.11 from host and virtual machine to ensure that network is working well. 

> If you need to display all containers logs **docker ps -a | grep -v CONTAINER| awk '{system("docker logs "$1)}'**.


#### Useful commands

##### internet gateway

> use `ip route` to retrieve the default network

##### Iptables

1. list iptables content: **iptables -S**
1. flush temporary iptables: **iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT**
1. definitively reset iptables **cp /etc/iptables/empty.rules /etc/iptables/iptables.rules && systemctl restart iptables.service**

##### Remote connection

1. connection: **ssh root@192.168.56.101**

### Installation

yum install git vim -y

git clone https://github.com/gshipley/installcentos/

./install-openshift.sh

Domain to use: (81.57.127.51.nip.io): **192.168.56.101**
Username: (root): **sandbox**
Password: (password): **sandbox**
OpenShift Version: (3.11): 
IP: (192.168.56.101):
API Port: (8443):
Do you wish to enable HTTPS with Let's Encrypt? : 2

> The domain to use correspond to the virtual machine IP.
> Let's Encrypt will not be installed because my IP used as domain to use is not public



******
* Your console is https://console.192.168.56.101:8443
* Your username is sandbox 
* Your password is sandbox 
*
* Login using:
*
$ oc login -u sandbox -p sandbox https://console.192.168.56.101:8443/
******

slow connection

docker pull docker.io/openshift/origin-control-plane:v3.11 && \
  docker pull docker.io/openshift/origin-control-plane:v3.11.0 && \
  docker pull docker.io/openshift/origin-pod:v3.11 && \
  docker pull docker.io/openshift/origin-pod:v3.11.0 && \
  docker pull docker.io/openshift/origin-node:v3.11 && \
  docker pull docker.io/openshift/origin-node:v3.11.0 && \
  docker pull docker.io/openshift/origin-haproxy-router:v3.11 && \
  docker pull docker.io/openshift/origin-haproxy-router:v3.11.0 && \
  docker pull docker.io/openshift/origin-deployer:v3.11 && \
  docker pull docker.io/openshift/origin-deployer:v3.11.0 && \
  docker pull docker.io/openshift/origin-template-service-broker:v3.11 && \
  docker pull docker.io/openshift/origin-template-service-broker:v3.11.0 && \
  docker pull docker.io/openshift/origin-docker-registry:v3.11 && \
  docker pull docker.io/openshift/origin-docker-registry:v3.11.0 && \
  docker pull docker.io/openshift/origin-console:v3.11 && \
  docker pull docker.io/openshift/origin-console:v3.11.0 && \
  docker pull docker.io/openshift/origin-service-catalog:v3.11 && \
  docker pull docker.io/openshift/origin-service-catalog:v3.11.0 && \
  docker pull docker.io/openshift/origin-web-console:v3.11 && \
  docker pull docker.io/openshift/origin-web-console:v3.11.0 && \
  docker pull docker.io/cockpit/kubernetes:latest && \
  docker pull quay.io/coreos/cluster-monitoring-operator:v0.1.1 && \
  docker pull quay.io/coreos/prometheus-config-reloader:v0.23.2 && \
  docker pull quay.io/coreos/prometheus-operator:v0.23.2 && \
  docker pull docker.io/openshift/prometheus-alertmanager:v0.15.2 && \
  docker pull docker.io/openshift/prometheus-node-exporter:v0.16.0 && \
  docker pull docker.io/openshift/prometheus:v2.3.2 && \
  docker pull docker.io/grafana/grafana:5.2.1 && \
  docker pull quay.io/coreos/kube-rbac-proxy:v0.3.1 && \
  docker pull quay.io/coreos/etcd:v3.2.22 && \
  docker pull quay.io/coreos/kube-state-metrics:v1.3.1 && \
  docker pull docker.io/openshift/oauth-proxy:v1.1.0 && \
  docker pull quay.io/coreos/configmap-reload:v0.0.1

  
