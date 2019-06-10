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

Because I am running low on memory some features will not be presents.
To install metric feature you will need at least 4Gb of memory.
To install logging feature you will need at least 16Gb of memory.
Theses requirements are defined in *install-openshift.sh* (we will deal with it in next paragraphs).
I guess 32Gb of memory is required.

**Why not version 4.0 of OpenShift ?**

Version 4.0 does not rely on Ansible. A script is provided to install OpenShift on *AWS* or *Azure* only (not Bare Metal).
Installing it on AWS create several EC2 instances (and I don't want to put so much money on my sandbox)

#### References:

All kudos go to Grant Shipley and other contributors who have provided this great repo :
- https://github.com/gshipley/installcentos/
- https://www.youtube.com/watch?v=ZkFIozGY0IA
- https://www.youtube.com/watch?v=S7HoJ09oYn0

The script *install-openshift.sh* is a gold mine :)

#### Prerequisites:

- VirtualBox installed
- CentOS-7-x86_64-Minimal-1810.iso Image

The sandbox will run on a Virtual machine having two cpu with 5Gb of ram. (My Host is an HP Omen Intel(R) Core(TM) i5-6300HQ CPU @ 2.30GHz with 8Gb of ram)

To install OpenShift we will use script provided by Grant Shipley (see references). Big Thanks to him.
Do not hesitate to look on it to understand how it works.

#### Installation

Here is a step by step installation taking from this video: https://www.youtube.com/watch?v=ZkFIozGY0IA

1. Create Virtual machine



2. Install OpenShift

1.x update packages
1.x install git
1.x 
clone
install

//
connect as sandbox

ip address show
> get ip address of enp0s3

ssh root@192.168.43.243
yum update
yum install git
git clone https://github.com/gshipley/installcentos.git
cd installcentos
./install-openshift.sh




wait :)

> Running the interactive mode will generate 200 persistent volumes of 500Gb each in the cluster.



3. Install Let's Encrypt Certificate

HowTo is available here:

- https://github.com/gshipley/installcentos/
- https://www.youtube.com/watch?v=S7HoJ09oYn0

#### Tips

1. Lot of memory and cpu is better to have all features and be able to run applications without missing cpu core or memory.

Some times, my pod stay in pending state because cpu millicores is missing, or not enough memory is available.

2. Network changes

We need to reroute the sandbox domain to point to internal ip of the virtual machine.
In the virtual machine, the old ip must be added on the network interface.

//TODO developer


