# OpenShift sandbox

## main goal

Create a sandbox running Openshift.

keywords: OpenShift 3.11, VirtualBox, CentOS 7 1810, Bare Metal Server

### installation sandbox

> OpenShift is intimately linked with RedHat products like RedHat RHEL7 (enterprise grade product) or CentOS7 (OpenSource version of RHEL7);
> Using other distribution is not supported and will not work as expected;
> Some software dependencies last version are not supported by OpenShift like Docker where only version 1.13.1 is supported.

This tutorial used a VirtualBox instance to understand how to setup OpenShift on a full system installation. However it is possible to reproduce it on a real bare metal server.

**What will be installed ?**

The version of OpenShift 3.11 under a virtual machine.

**Why not version 4.0 of OpenShift ?**

Version 4.0 does not rely on Ansible anymore. A script is provided to install OpenShift on *AWS* or *Azure* only (not Bare Metal Server).
Installing it on AWS create several EC2 instances: one master, two nodes and a worker.

This documentation is about a full OpenShift instance in one server.

#### Prerequisites:

- VirtualBox installed
- CentOS-7-x86_64-Minimal-1810.iso Image

#### Installation

Binary: OpenShift 3.11 is available as prepackaged binary from okd.io however I discourage the use of them because some features like cluster ui, metrics and logging are not available.

We will install a "real" OpenShift will all expected feature in next paragraph.

To install OpenShift on VirtualBox step by step please follow theses videos from the OpenShift youtube chanel:
- https://www.youtube.com/watch?v=ZkFIozGY0IA
- https://www.youtube.com/watch?v=S7HoJ09oYn0

Code to use is available here: gt

##### configuration

The virtual machine use enp0s3 as internal network.

Here is my configuration:

CentOS user: sandbox

install-openshift:
Domain to use: (83.115.164.226.nip.io): sandbox.nip.io
Username: (root): sandbox
Password: (password): what you want as password
OpenShift Version: (3.11):
IP: (192.168.1.13):
API Port: (8443):

Let's encrypt is not used

My Host on which VirtualBox is running is an Arch linux.
The IP of my virtual machine running OpenShift is 192.168.1.13.
To translate the domain name *sandbox* to the machine I have added this entry in XXX

oc login -u sandbox -p admin https://console.sandbox.nip.io:8443/


https://console.sandbox.nip.io:8443/swaggerui/

rajouter le paragraphe concernant la configuration presente dans master yaml

TODO !!!

TODO setup DNS

Host:
echo "192.168.1.13    console.sandbox.nip.io  console.sandbox.nip.io" >> /etc/hosts

##### Additional Information

The script *install-openshift.sh* used to install OpenShift will check the memory available to install or not some features.

So, to install metric feature you will need at least 4Gb of memory, to install the logging feature you will need at least 16gb of memory.

You can have a look to the content of *install-openshift.sh* to understand how OpenShift is setting up.

Running the interactive mode will generate 200 persistent volumes of 500Gb each in the cluster.

#### Going further

I am using a 

// TODO j'install sandbox avec orange puis je test avec 



connect as sandbox

ip address show
> get ip address of enp0s3

##### diagnostic OpenShift

machine virtuelle:

get router ip: curl -s ipinfo.io/ip

ping 83.115.164.226.nip.io
ping sandbox.nip.io

docker ps -a | grep -v CONTAINER| awk '{system("docker logs "$1)}'

###### no dns 8.8.8.8 defined

nmcli:
DNS configuration:
        servers: 192.168.1.1
        domains: home
        interface: enp0s3

do:
nmcli con mod enp0s3 ipv4.dns "8.8.8.8 8.8.4.4"
nmcli con mod enp0s3 ipv4.ignore-auto-dns yes
service network restart

result:
DNS configuration:
        servers: 8.8.8.8 8.8.4.4
        interface: enp0s3

######## flut
/etc/environment


REFAIRE installation en SSH via ROOT !!!
c'est peut être cela le problème ...




## conf default:


Domain to use: (83.115.164.226.nip.io): 
Username: (root): sandbox
Password: (password): admin
OpenShift Version: (3.11): 
IP: (192.168.1.15): 
API Port: (8443):

si ok verifier les conf /etc/resolv.conf /etc/hosts...



Your console is https://console.81.57.127.51.nip.io:8443
* Your username is sandbox 
* Your password is sandbox 
*
* Login using:
*
$ oc login -u sandbox -p sandbox https://console.81.57.127.51.nip.io:8443/

curl -s ipinfo.io/ip

ip addr show|grep 192
cat /etc/origin/master/master-config.yaml|grep 192
vim /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo "IPADDR=192.168.0.4" >> /etc/sysconfig/network-scripts/ifcfg-enp0s3
systemctl restart network


systemctl restart sshd
systemctl status sshd
netstat -tunap | grep ssh


redirection ip router vers ip interne virtualbox
sudo iptables -t nat -A OUTPUT -d 81.57.127.51 -j DNAT --to-destination 192.168.0.4


curl -k https://console.sandbox.nip.io:8443/console/


depuis le host:
echo "192.168.0.48    console.sandbox.nip.io  console.sandbox.nip.io" >> /etc/hosts
echo "192.168.0.48    console.apps.sandbox.nip.io  console.apps.sandbox.nip.io" >> /etc/hosts MARCHE PAS console cluster indisponible :(

ok la console est inaccessible si je passe par XXX.nip.io ...

>passage apr un dns externe OU alors IP FIXE !