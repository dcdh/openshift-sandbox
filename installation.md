# OpenShift sandbox

git clone https://github.com/dcdh/openshift-sandbox.git

## Main goal

As a developer, I want to create a sandbox running OpenShift version 3.11 (last version of the 3.XX releases), in order to practice OpenShift.

This sandbox must not be dependent of the dynamic network defined by the Internet Service Provider router for the connected interface.

**keywords**: OpenShift 3.11, VirtualBox, CentOS 7 1810, Bare Metal Server

> OpenShift is intimately linked with RedHat products like RedHat RHEL7 (enterprise grade product) or CentOS7 (OpenSource version of RHEL7);
>
> Using other distribution is not supported by this document and will not work as expected;
>
> Some software dependencies last version are not supported by OpenShift like Docker where only version 1.13.1 is supported.

This tutorial used a VirtualBox instance to understand how to setup OpenShift on a full system installation. Hopefully it is possible to reproduce it on a real bare metal server.
Using a bare metal server will need a real dns name to make it accessible from the web (not covered by this documentation).

**What will be installed ?**

The version of OpenShift 3.11 under a virtual machine.

**Why not install version 4.xx of OpenShift ?**

Version 4.xx have introduced a new architecture compound by more than 1 server.

This documentation is about installing a full OpenShift instance (master and node) in one server.

> ## References
> [virtualbox-host-only-with-internet](https://unix.stackexchange.com/questions/383791/virtualbox-host-only-with-internet)
>
> [OpenShift installation sources](https://github.com/gshipley/installcentos/)
>
> [OpenShift installation part1](https://www.youtube.com/watch?v=ZkFIozGY0IA)
>
> [OpenShift installation part2](https://www.youtube.com/watch?v=S7HoJ09oYn0)

## Prerequisites

- VirtualBox installed
- CentOS-7-x86_64-Minimal-1810.iso Image
- an active internet connection

## VirtualBox

> We will use a "host-only" interface to ensure that the virtual machine will use here own static network.
>
> Host will be set up to allow the virtual machine to access internet (not the case by default).

### Host Network Configuration

Add a `vboxnet0` network using theses values:

![host network vboxnet0 interface](/virtualbox_setup/host_network_vboxnet0_interface.png)

![host network vboxnet0 server_dhcp](/virtualbox_setup/host_network_vboxnet0_server_dhcp.png)

### Guest Virtual Machine configuration

#### Characteristics

1. **Hard drive** 80Go
1. **CPU** 4
1. **Memory** at least 17Go
1. **Network**

![virtualBox_interface_1](/virtualbox_setup/virtualBox_interface_1.png)

#### Installation

> Please follow CentOS guest installation from `OpenShift installation part1`
>
> #### /!\ Do not install Openshift by running the script `install-openshift.sh` yet.

**Guest Network setup**

1. From the console copy replace the content of this file `/etc/sysconfig/network-scripts/ifcfg-enp0s3` by the file `ifcfg-enp0s3` provided in this repo.
2. Restart the network `systemctl restart network.service`.

> Now you can connect the guest virtual machine from the host by using the command `ssh root@192.168.56.101`

> If your phone use IPV6 ensure to activate IPV6 on you guest wifi connection
![IPV6_setup](/wifi_ipv6.png)
> On your (Android) phone ensure that IPV4 and IPV6 protocols are both used !
![IPV4_IPV6_android_setup](/wifi_android.png)

## Host Network Configuration (on arch linux as root)

cp /etc/iptables/empty.rules /etc/iptables/iptables.rules

systemctl enable iptables.service

systemctl start iptables.service

sysctl -w net.ipv4.ip_forward=1

sysctl -w net.ipv6.conf.all.forwarding=1

printf "net.ipv4.ip_forward=1\n" >> /etc/sysctl.d/30-ipforward.conf

printf "net.ipv6.conf.all.forwarding=1\n" >> /etc/sysctl.d/30-ipforward.conf

iptables -t filter -I FORWARD --in-interface vboxnet0 --out-interface `wlo1` --source 192.168.56.0/24 -j ACCEPT
> Replace `wlo1` by your interface connected on internet.
>
> In my case the interface connected with internet is my wifi (wlo1).
>
> Use `ip route|grep default` to find your interface connected with internet.

iptables -t filter -I FORWARD --in-interface `wlo1` --out-interface vboxnet0 --destination 192.168.56.0/24 -j ACCEPT
> Replace `wlo1` by your interface connected on internet.
>
> In my case the interface connected with internet is my wifi (wlo1).
>
> Use `ip route|grep default` to find your interface connected with internet.

iptables -t nat -I POSTROUTING -o `wlo1` -j MASQUERADE
> Replace `wlo1` by your interface connected on internet.
>
> In my case the interface connected with internet is my wifi (wlo1).
>
> Use `ip route|grep default` to find your interface connected with internet.

iptables-save > /etc/iptables/iptables.rules

systemctl restart iptables.service

systemctl enable dnsmasq.service

systemctl start dnsmasq.service

> #### Now doing a `ping 8.8.8.8` from the Virtual Machine should return:
> PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
>
> 64 bytes from 8.8.8.8: icmp_seq=1 ttl=53 time=25.3 ms

### Guest Virtual Machine installation

yum install -y docker-1.13.1 && systemctl start docker && systemctl enable docker

> pull images used in case your connection is too slow leading to installation failure due to not enough time allowed by installation probes

    docker pull docker.io/openshift/origin-cluster-monitoring-operator:v3.11 && \
    docker pull docker.io/openshift/origin-logging-fluentd:v3.11 && \
    docker pull docker.io/openshift/origin-logging-kibana5:v3.11 && \
    docker pull docker.io/openshift/origin-metrics-server:v3.11 && \
    docker pull docker.io/openshift/origin-metrics-heapster:v3.11 && \
    docker pull docker.io/openshift/origin-metrics-hawkular-metrics:v3.11 && \
    docker pull docker.io/openshift/origin-metrics-schema-installer:v3.11 && \
    docker pull docker.io/openshift/origin-metrics-cassandra:v3.11 && \
    docker pull docker.io/cockpit/kubernetes:latest && \
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

> nexus related images

    docker pull sonatype/nexus3:3.6.0

> ci related images
> dcdh1983/jenkins-agent-maven-35-graalvm-centos7 : https://github.com/dcdh/jenkins-agent-maven-35-graalvm-centos7.git

    docker pull openshift/jenkins-slave-nodejs-centos7:v3.11 && \
    docker pull openshift/jenkins-agent-maven-35-centos7:v3.11 && \
    docker pull openshift/jenkins-slave-maven-centos7:v3.11 && \
    docker pull openshift/jenkins-agent-nodejs-8-centos7:v3.11 && \
    docker pull openshift/jenkins-slave-base-centos7:v3.11 && \
    docker pull openshift/jenkins-2-centos7:v3.11

yum install git vim telnet -y

git clone https://github.com/okd-community-install/installcentos

cd installcentos

./install-openshift.sh

    Domain to use: (81.57.127.51.nip.io): 192.168.56.101.nip.io
    Username: (root): sandbox
    Password: (password): sandbox
    OpenShift Version: (3.11): 
    IP: (192.168.56.101):
    API Port: (8443):
    Do you wish to enable HTTPS with Let's Encrypt? : 2
> The domain to use correspond to the virtual machine IP.
> Let's Encrypt will not be installed because my IP used as domain to use is not public

Wait a lot of time !
Next enjoy ^^

    ******
    * Your console is https://console.192.168.56.101.nip.io:8443
    * Your username is sandbox 
    * Your password is sandbox 
    *
    * Login using:
    *
    $ oc login -u sandbox -p sandbox https://console.192.168.56.101:8443/
    ******

## Additional Information

The script `install-openshift.sh` used to install OpenShift will check the memory available to install or not some features.

So, to install metric feature you will need at least 4Gb of memory, to install the logging feature you will need at least 16gb of memory.

You can have a look to the content of `install-openshift.sh` to understand how OpenShift is setting up.

Running the interactive mode will generate 200 persistent volumes of 500Gb each in the cluster.

OpenShift config files are located here `/etc/origin/`. It may be useful to see the content of `master-config.yaml`.

To show network address ip: `ip address show`.

Get router ip: `curl -s ipinfo.io/ip`.

If you need to display all containers logs `docker ps -a | grep -v CONTAINER| awk '{system("docker logs "$1)}'`.

Use `ip route` to retrieve the default network

> Iptables

1. list iptables content: `iptables -S`
1. flush temporary iptables: `iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT`
1. definitively reset iptables `cp /etc/iptables/empty.rules /etc/iptables/iptables.rules && systemctl restart iptables.service`
