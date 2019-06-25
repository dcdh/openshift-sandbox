# OpenShift sandbox

## main goal

Create a sandbox running OpenShift version 3.11 (last version of the 3.XX releases).

keywords: OpenShift 3.11, VirtualBox, CentOS 7 1810, Bare Metal Server

> Please read all this documentation before starting installing OpenShift.

### installation sandbox

> OpenShift is intimately linked with RedHat products like RedHat RHEL7 (enterprise grade product) or CentOS7 (OpenSource version of RHEL7);
> Using other distribution is not supported by this document and will not work as expected;
> Some software dependencies last version are not supported by OpenShift like Docker where only version 1.13.1 is supported.

This tutorial used a VirtualBox instance to understand how to setup OpenShift on a full system installation. However it is possible to reproduce it on a real bare metal server.
Using a bare metal server will need a real dns name to make it accessible from the web (not covered by this documentation).

**What will be installed ?**

The version of OpenShift 3.11 under a virtual machine.

**Why not install version 4.0 of OpenShift ?**

Version 4.0 does not rely on Ansible anymore. A script is provided to install OpenShift on *AWS* or *Azure* only (not Bare Metal Server).
Installing it on AWS create several EC2 instances: one master, two nodes and a worker. So by the new architecture introduced by the 4.XX releases more than 1 server is needed.

This documentation is about installing a full OpenShift instance in one server.

**Infrastructure**

Internet connection is mandatory

The host will have this IP : 10.0.0.10 defined on the interface use to connect to internet (like the wifi wlo1)

The virtual machine will be configured using this setup:
- 2 cpu
- at least 5Gb of ram
- bridged network using the interface use to connect with internet (in my case wlo1)

The IP used by the virtual machine will be defined to 10.0.0.11;

In further paragraph I will give every commands needed to setup host IP and virtual machine IP and also DNS entries.

#### Prerequisites

- VirtualBox installed
- CentOS-7-x86_64-Minimal-1810.iso Image
- an active internet connection

#### Installation

> Binary: OpenShift 3.11 is available as prepackaged binary from okd.io. However I discourage the use of them because some features like cluster ui, metrics and logging are not available.

##### Prerequisites

We will install a "real" OpenShift with all expected features in next paragraph.

To install OpenShift on VirtualBox step by step please follow theses videos from the **OpenShift** youtube chanel:
- https://www.youtube.com/watch?v=ZkFIozGY0IA
- https://www.youtube.com/watch?v=S7HoJ09oYn0

Code to use is available here: **https://github.com/gshipley/installcentos/**

The virtual machine use enp0s3 as internal network.

##### Procedure

1. Install CentOS

2. Install useful tools like vim and telnet in the virtual machine

> (from host) ssh root@IP
> yum install vim, telnet

3. Define host IP (Arch linux from my case)

> from host : **sudo ip addr add 10.0.0.10/24 dev wlo1**
> Warning: each time the network connect to internet you will have to re-run the command.
> TODO : find a way to make it persistent

4. Define virtual machine IP

4.1. connect to the virtual machine (using ssh or other)
4.2. copy ifcfg-enp0s3:1 into /etc/sysconfig/network-scripts/ifcfg-enp0s3:1
4.3. ensure that **ifcfg-enp0s3:1** as same rights, owner and group than **ifcfg-enp0s3** (you can use **cp -p** and next replace all the content)
4.4. restart the network **systemctl restart network**

> Now doing this command **ip addr show|grep 10.0.0.11** should return **inet 10.0.0.11/24 brd 10.0.0.255 scope global noprefixroute enp0s3:1**
> So the addresse IP **10.0.0.11** is well linked to **enp0s3:1**

5. Change default root

> By default, OpenShift use the default route assigned to define master's ip. However when using a dynamic IP, OpenShift may not start after server reboot and a new ip assignment.
> Internally, Ansible playbook use the property 'ansible_default_ipv4' to define master's ip.

route add default gw 10.0.0.11

FUCK route add n'est pas persistent au redemmarrage !!
FUCK et la cela ne marche pas le ping !!! WHOUHOU je suis dans la merde
FUCK et ce que je peux avoir une route secondaire ????

> to check which route is active by default `ip -4 route get 8.8.8.8` 

6. Install OpenShift

6.1. Run the script **install-openshift.sh**
6.2. Answer questions with theses responses:

Domain to use: (81.57.127.51.nip.io): **10.0.0.11**
Username: (root): **sandbox**
Password: (password): **sandbox**
OpenShift Version: (3.11): 
IP: (192.168.0.22): **10.0.0.11**
API Port: (8443):

> The domain to use correspond to the virtual machine IP.
> As you can see a 'dynamic' IP (192.168.0.22) is proposed. I ensure to use the one fixed on my interface (ie: 10.0.0.11)
> Let's Encrypt will not be installed because my IP used as domain to use is not public

6.3. Wait a lot of time

6.4. Add dns entries in host

> I need to translate domain and sub-domain addresses represented as **sub-domain.10.0.0.11** to the virtual machine running OpenShift IP address **10.0.0.11**

echo "10.0.0.11       console.10.0.0.11       console.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       console.apps.10.0.0.11  console.apps.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       prometheus-k8s-openshift-monitoring.apps.10.0.0.11 prometheus-k8s-openshift-monitoring.apps.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       alertmanager-main-openshift-monitoring.apps.10.0.0.11 alertmanager-main-openshift-monitoring.apps.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       grafana-openshift-monitoring.apps.10.0.0.11 grafana-openshift-monitoring.apps.10.0.0.11" >> /etc/hosts

> Keep in mind that the dns entries in the host must be updated when exposing a new application route from the virtual machine running OpenShift.

> With 5gb of ram I could not install logging feature. So maybe you should add another entries in your hosts corresponding to logging web interfaces.

6.5. reboot

reboot

7. login :)

You can login by using your browser from your host and this URL **https://console.apps.10.0.0.11**

Or by using this command in the virtual machine from the host:
- ssh sandbox@10.0.0.11
- oc login -u sandbox -p admin https://console.10.0.0.11:8443/

##### Additional Information

The script **install-openshift.sh** used to install OpenShift will check the memory available to install or not some features.

So, to install metric feature you will need at least 4Gb of memory, to install the logging feature you will need at least 16gb of memory.

You can have a look to the content of *install-openshift.sh* to understand how OpenShift is setting up.

Running the interactive mode will generate 200 persistent volumes of 500Gb each in the cluster.

#### Tips

> Check that OpenShift is running from the virtual machine by using this command **curl -k https://console.apps.10.0.0.11/**.

> OpenShift config files are located here **/etc/origin/**. It may be useful to see the content of **master-config.yaml**.

> To show network address ip: **ip address show**.

> Get router ip: **curl -s ipinfo.io/ip**.

> You can ping 10.0.0.10 and 10.0.0.11 from host and virtual machine to ensure that network is working well. 

> If you need to display all containers logs **docker ps -a | grep -v CONTAINER| awk '{system("docker logs "$1)}'**.
