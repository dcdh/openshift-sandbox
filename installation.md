# Installation

> ## References
> [virtualbox-host-only-with-internet](https://unix.stackexchange.com/questions/383791/virtualbox-host-only-with-internet)

## VirtualBox

> We will use a "host-only" interface to ensure that the virtual machine will use here own static network.
> Host will be set up to allow the virtual machine to access internet (not the case by default)

### Network Configuration

![host network vboxnet0 interface](/virtualbox_setup/host_network_vboxnet0_interface.png)

![host network vboxnet0 server_dhcp](/virtualbox_setup/host_network_vboxnet0_server_dhcp.png)

### Virtual Machine

#### Characteristics

1. **Hard drive** 80Go
1. **CPU** 2
1. **Memory** 4096Mo

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


echo "192.168.56.101  console.192.168.56.101       console.192.168.56.101" >> /etc/hosts
echo "192.168.56.101  console.apps.192.168.56.101  console.apps.192.168.56.101" >> /etc/hosts
echo "192.168.56.101  prometheus-k8s-openshift-monitoring.apps.192.168.56.101 prometheus-k8s-openshift-monitoring.apps.192.168.56.101" >> /etc/hosts
echo "192.168.56.101  alertmanager-main-openshift-monitoring.apps.192.168.56.101 alertmanager-main-openshift-monitoring.apps.192.168.56.101" >> /etc/hosts
echo "192.168.56.101  grafana-openshift-monitoring.apps.192.168.56.101 grafana-openshift-monitoring.apps.192.168.56.101" >> /etc/hosts

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

TODO tester le contenu de /etc/origin/master/master-xxx.yml l'@ IP utilisé !!!!



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

  
