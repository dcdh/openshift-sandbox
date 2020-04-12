# OKD 4

## Main Goal

Install OKD 4 under CentOS 7. KVM will be used to virtualize okd infrastructure.

**keywords**: OKD 4, KVM, QEMU, libvert, CentOS 7, Bare Metal Server, Not HA installation

> ## References
> [kvm tutorial](https://www.cyberciti.biz/faq/how-to-install-kvm-on-centos-7-rhel-7-headless-server/)
>
> [kvm-networking](https://amoldighe.github.io/2017/12/20/kvm-networking/)
> 
> [okd installation](https://www.cyberciti.biz/faq/how-to-install-kvm-on-centos-7-rhel-7-headless-server/)
>
> [installing-bare-metal](https://docs.openshift.com/container-platform/4.3/installing/installing_bare_metal/installing-bare-metal.html)
>
> [ocp43-installation-vmware](https://labs.consol.de/container/platform/openshift/2020/01/31/ocp43-installation-vmware.html)
>
> [installing-openshift-4-1-using-libvirt-and-kvm](https://servicesblog.redhat.com/2019/07/11/installing-openshift-4-1-using-libvirt-and-kvm/)
>
> [how-to-create-and-configure-bridge-networking-for-kvm-in-linux](https://computingforgeeks.com/how-to-create-and-configure-bridge-networking-for-kvm-in-linux/)
>
> [custom-nat-based-network](https://jamielinux.com/docs/libvirt-networking-handbook/custom-nat-based-network.html)
>
> [libvirt-centos-cloud-image](http://saule1508.github.io/libvirt-centos-cloud-image/)
>
> [configuring-qemu-bridge-helper-after-access-denied-by-acl-file-error](https://blog.christophersmart.com/2016/08/31/configuring-qemu-bridge-helper-after-access-denied-by-acl-file-error/)
> How to set up network bridge access
>
> [kvm-install-vm](https://github.com/giovtorres/kvm-install-vm)
> Useful script to create kvm virtual machines
> 
> [DNS_Bind](https://github.com/openshift/okd/blob/4.4.0-0.okd-2020-01-28-022517/Documentation/UPI/Requirements/DNS_Bind.md)
> How to set up dns
>

/!\ do not use `gnome boxes` to handle, visualize guest virtual machine as it will automatically save and suspend them if no activity during 60 seconds and save and suspend whe exiting boxes.
There is no option to change these behaviors :(
We do not want to suspend them. Use `virt-manager` instead :)

## KVM

```
# yum install qemu-kvm libvirt libvirt-python libguestfs-tools virt-install virt-manager -y && \
    systemctl enable libvirtd && \
    systemctl start libvirtd
```

## OKD

In the following part we will install an instance of OKD compound of :
- one Control Plane (aka Master)
- one Worker (aka Compute)
- one Bootstrap

This installation is not high available as if the control plane, or the worker fails the cluster will fail too.
The main objective is to run a local instance as a testing purpose.

| Machine            | CPU | RAM  | Storage | OS            | static IP  | mac               | DNS                                  |
| ------------------ | ---:| ----:| -------:| -------------:| ----------:| ----------------: | :------------------------------------|
| DNS                |   1 |  1GB |    10GB | CentOS 7      |  10.0.6.10 | 52:54:00:00:06:10 | dns.okd.local                        |
| Container Registry |   1 |  8GB |    25GB | Fedora CoreOS |  10.0.6.11 | 52:54:00:00:06:11 | container-registry.sandbox.okd.local |
| Load Balancer      |   1 |  1GB |    10GB | CentOS 7      |  10.0.5.57 | 52:54:00:00:05:57 | lb.sandbox.okd.local                 |
| Control Plane      |   1 |  8GB |    25GB | Fedora CoreOS |  10.0.5.59 | 52:54:00:00:05:59 | control-plane-0.sandbox.okd.local    |
| Control Plane      |   1 |  8GB |    25GB | Fedora CoreOS |  10.0.5.60 | 52:54:00:00:05:60 | control-plane-1.sandbox.okd.local    |
| Control Plane      |   1 |  8GB |    25GB | Fedora CoreOS |  10.0.5.61 | 52:54:00:00:05:61 | control-plane-2.sandbox.okd.local    |
| Worker             |   4 |  8GB |    25GB | Fedora CoreOS |  10.0.5.62 | 52:54:00:00:05:62 | compute-0.sandbox.okd.local          |
| Bootstrap          |   1 |  8GB |    25GB | Fedora CoreOS |  10.0.5.58 | 52:54:00:00:05:58 | bootstrap.sandbox.okd.local          |

## Networks

### Networks definitions

#### openshift-dns

/!\ in root

```
# cat << 'EOF' > openshift-dns-network.xml
<network>
  <name>openshift-dns</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr-os-dns' stp='on' delay='0'/>
  <mac address='52:54:00:00:06:00'/>
  <domain name='sandbox.okd.local' localOnly='no'/>
  <ip address='10.0.6.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.0.6.10' end='10.0.6.254'/>
      <host mac='52:54:00:00:06:10' name='dns.okd.local' ip='10.0.6.10'/>
    </dhcp>
  </ip>
</network>
EOF
```

```
# virsh net-define openshift-dns-network.xml && virsh net-start openshift-dns && virsh net-autostart openshift-dns
```

#### openshift-cluster

/!\ in root

```
# cat << 'EOF' > openshift-cluster-network.xml
<network>
  <name>openshift-cluster</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr-os-cl' stp='on' delay='0'/>
  <mac address='52:54:00:00:05:00'/>
  <domain name='sandbox.okd.local' localOnly='no'/>
  <dns>
    <forwarder addr='10.0.6.10'/>
  </dns>
  <ip address='10.0.5.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.0.5.10' end='10.0.5.254'/>
      <host mac='52:54:00:00:05:57' name='lb.sandbox.okd.local' ip='10.0.5.57'/>
      <host mac='52:54:00:00:05:59' name='control-plane-0.sandbox.okd.local' ip='10.0.5.59'/>
      <host mac='52:54:00:00:05:62' name='compute-0.sandbox.okd.local' ip='10.0.5.62'/>
      <host mac='52:54:00:00:05:58' name='bootstrap.sandbox.okd.local' ip='10.0.5.58'/>
    </dhcp>
  </ip>
</network>
EOF
```

```
# virsh net-define openshift-cluster-network.xml && virsh net-start openshift-cluster && virsh net-autostart openshift-cluster
```

Now when doing this `virsh net-list --all` you should get theses networks:

```
 Nom                  État      Démarrage automatique Persistent
----------------------------------------------------------
 default              actif      yes           yes
 openshift-cluster    actif      yes           yes
 openshift-dns        actif      yes           yes
```

### permissions

/!\ in regular user (user who will be in charge to create machines)

You will have an issue when creating virtual machines using bridges `virbr-os-dns` and `virbr-os-cl` because you don't have access to them.

The following paragraph will update permissions to give access to **all** bridges. 

allow all bridge permissions for user

```
# echo "allow all" | sudo tee /etc/qemu-kvm/${USER}.conf && \
    echo "include /etc/qemu-kvm/${USER}.conf" | sudo tee --append /etc/qemu-kvm/bridge.conf && \
    sudo chown root:${USER} /etc/qemu-kvm/${USER}.conf && \
    sudo chmod 640 /etc/qemu-kvm/${USER}.conf
```

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# fck WEB SERVER to expose OKD
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



## Virtual machines

/!\ in regular user (user who will be in charge to create machines)

```
# git clone https://github.com/giovtorres/kvm-install-vm.git
```

### DNS

Objective: install dns virtual machine:
- CPU: 1
- RAM: 1GB
- Storage: 10GB
- OS: CentOS 7
- static IP: 10.0.6.10
- mac: 52:54:00:00:06:10
- dns: dns.okd.local

```
# ./kvm-install-vm create -a -t centos7 -c 1 -d 10 -b virbr-os-dns -D sandbox.okd.local -M 52:54:00:00:06:10 dns.okd.local
```

```
# ssh centos@10.0.6.10
```

```
# sudo yum install dnsmasq -y
```

```
# sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
```

```
# cat << 'EOF' | sudo tee /etc/dnsmasq.conf
local=/sandbox.okd.local/
address=/apps.sandbox.okd.local/10.0.6.10
srv-host=_etcd-server-ssl._tcp.sandbox.okd.local,control-plane-0.sandbox.okd.local,2380,0,10
no-hosts
addn-hosts=/etc/dnsmasq.openshift.addnhosts
conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig
EOF
```
      
```
# cat << 'EOF' | sudo tee /etc/dnsmasq.openshift.addnhosts
10.0.6.10 dns.okd.local
10.0.5.57 lb.sandbox.okd.local  api.sandbox.okd.local  api-int.sandbox.okd.local
10.0.5.58 bootstrap.sandbox.okd.local
10.0.5.59 control-plane-0.sandbox.okd.local  etcd-0.sandbox.okd.local
10.0.5.62 compute-0.sandbox.okd.local
EOF
```

```
# sudo systemctl enable dnsmasq && \
   sudo systemctl start dnsmasq
```

> Debug
sudo systemctl status dnsmasq

### Load Balancer

Objective: install load balancer virtual machine:
- CPU: 1
- RAM: 1GB
- Storage: 10GB
- OS: CentOS 7
- static IP: 10.0.5.57
- mac: 52:54:00:00:05:57
- dns: lb.sandbox.okd.local

```
# ./kvm-install-vm create -a -t centos7 -c 1 -d 10 -b virbr-os-cl -D sandbox.okd.local -M 52:54:00:00:05:57 lb.sandbox.okd.local
```

Even if we have one instance of the Control Plane we will setup an HA Proxy (it will next be bind with a domain name).

```
# ssh centos@10.0.5.57
```

```
# sudo yum install haproxy -y
```

Setup `haproxy` configuration with this configuration

```
# sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
```

```
# cat << 'EOF' | sudo tee /etc/haproxy/haproxy.cfg
# Global settings
#---------------------------------------------------------------------
global
    maxconn     20000
    log         /dev/log local0 info
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          300s
    timeout server          300s
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 20000

listen stats
    bind :9000
    mode http
    stats enable
    stats uri /

frontend ocp4_k8s_api_fe
    bind :6443
    default_backend ocp4_k8s_api_be
    mode tcp
    option tcplog

backend ocp4_k8s_api_be
    balance roundrobin
    mode tcp
    server      bootstrap 10.0.5.58:6443 check
    server      control-plane-0 10.0.5.59:6443 check

frontend ocp4_machine_config_server_fe
    bind :22623
    default_backend ocp4_machine_config_server_be
    mode tcp
    option tcplog

backend ocp4_machine_config_server_be
    balance roundrobin
    mode tcp
    server      bootstrap 10.0.5.58:22623 check
    server      control-plane-0 10.0.5.59:22623 check

frontend ocp4_http_ingress_traffic_fe
    bind :80
    default_backend ocp4_http_ingress_traffic_be
    mode tcp
    option tcplog

backend ocp4_http_ingress_traffic_be
    balance roundrobin
    mode tcp
    server      compute-0 10.0.5.62:80 check

frontend ocp4_https_ingress_traffic_fe
    bind :443
    default_backend ocp4_https_ingress_traffic_be
    mode tcp
    option tcplog

backend ocp4_https_ingress_traffic_be
    balance roundrobin
    mode tcp
    server      compute-0 10.0.5.62:443 check
EOF
```

```
# sudo setsebool -P haproxy_connect_any on && \
    sudo systemctl start haproxy && \
    sudo systemctl enable haproxy
```

























Now we need to resolve domain `sandbox.okd` and sub domains in our host to subnet `10.0.5.xxx`.

```
# sudo yum install bind -y
```

```
# sudo echo 'include "/etc/named/named.conf.local";' | sudo tee -a /etc/named.conf
```

```
# cat << 'EOF' | sudo tee /etc/named/named.conf.local
zone "sandbox.okd" {
    type master;
    file "/var/named/zones/db.sandbox.okd";
};

zone "5.0.10.in-addr.arpa" {
    type master;
    file "/var/named/zones/db.10.0.5";
};
EOF
```

```
# sudo mkdir /var/named/zones
```

```
# cat << 'EOF' | sudo tee /var/named/zones/db.sandbox.okd
$TTL    604800
@       IN      SOA     ns1.sandbox.okd. admin.sandbox.okd. (
                  1     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800     ; Negative Cache TTL
)

; name servers - NS records
    IN      NS      ns1

; name servers - A records
ns1.sandbox.okd.          IN      A       10.0.6.10

; OpenShift Container Platform Cluster - A records
bootstrap.sandbox.okd.local.        IN      A      10.0.5.58
control-plane-0.sandbox.okd.local.        IN      A      10.0.5.59
compute-0.sandbox.okd.local.        IN      A      10.0.5.62

; OpenShift internal cluster IPs - A records
api.sandbox.okd.local.    IN    A    10.0.6.10
api-int.sandbox.okd.local.    IN    A    10.0.6.10
*.apps.sandbox.okd.local.    IN    A    10.0.6.10
etcd-0.sandbox.okd.local.    IN    A     10.0.5.59
console-openshift-console.apps.sandbox.okd.local.     IN     A     10.0.6.10
oauth-openshift.apps.sandbox.okd.local.     IN     A     10.0.6.10

; OpenShift internal cluster IPs - SRV records
_etcd-server-ssl._tcp.sandbox.okd.local.    86400     IN    SRV     0    10    2380    etcd-0.ocp4-cluster-001
EOF
```

```
# cat << 'EOF' | sudo tee /var/named/zones/db.10.0.5
$TTL    604800
@       IN      SOA     ns1.sandbox.okd. admin.sandbox.okd. (
                  6     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800     ; Negative Cache TTL
)

; name servers - NS records
    IN      NS      ns1.sandbox.okd.

; name servers - PTR records
10.0.6.10    IN    PTR    ns1.sandbox.okd.

; OpenShift Container Platform Cluster - PTR records
10.0.5.58    IN    PTR    bootstrap.sandbox.okd.local.
10.0.5.59    IN    PTR    control-plane-0.sandbox.okd.local.
10.0.5.62    IN    PTR    compute-0.sandbox.okd.local.
EOF
```

```
# sudo systemctl enable --now named
```

### 
































### Network

```
As a VM
I want to have a static IP define in another subnet than the host
I want to access internet
I do not want to be accessible from the host outside
```

#### Virtual Machine

```
# sudo ssh-keygen -t ed25519 -C "VM Login ssh key" -N "" -f ~/.ssh/id_ed25519
```

Keep the fingerprint printed in the previous command. Something likes this:

```
The key fingerprint is:
SHA256:UU6iS/x4vtKZnQfzhP3O64XNVVKtWTxGASGlmmC+FAQ VM Login ssh key
```
so `UU6iS/x4vtKZnQfzhP3O64XNVVKtWTxGASGlmmC+FAQ VM Login ssh key`


```
# cat << 'EOF' | sed 's/HOSTNAME/centos7-dns/g' | sed 's/SSH_KEY/UU6iS\/x4vtKZnQfzhP3O64XNVVKtWTxGASGlmmC+FAQ VM Login ssh key/g' > meta-data
#cloud-config

# Hostname management
preserve_hostname: False
hostname: dns
fqdn: dns.okd.local

# Users
users:
    - default
    - name: dns
      groups: ['wheel']
      shell: /bin/bash
      sudo: ALL=(ALL) NOPASSWD:ALL
      ssh-authorized-keys:
        - ssh-ed25519 SSH_KEY
 
# Configure where output will go
output:
  all: ">> /var/log/cloud-init.log"
 
# configure interaction with ssh server
ssh_genkeytypes: ['ed25519', 'rsa']
 
# Install my public ssh key to the first user-defined user configured
# in cloud.cfg in the template (which is centos for CentOS cloud images)
ssh_authorized_keys:
  - ssh-ed25519 SSH_KEY

# set timezone for VM
timezone: Europe/Paris

# Remove cloud-init 
runcmd:
  - systemctl stop network && systemctl start network
  - yum -y remove cloud-init

EOF
```

```
# cp /var/lib/libvirt/boot/CentOS-7-x86_64-GenericCloud.qcow2 centos7-dns.qcow2
# export LIBGUESTFS_BACKEND=direct
# qemu-img create -f qcow2 -o preallocation=metadata centos7-dns.new.image 10G
# virt-resize --quiet --expand /dev/sda1 centos7-dns.qcow2 centos7-dns.new.image
# mv -f centos7-dns.new.image centos7-dns.qcow2
# mkisofs -o centos7-dns-cidata.iso -V cidata -J -r user-data meta-data
# virsh pool-create-as --name centos7-dns --type dir --target /var/lib/libvirt/images/centos7-dns


Attention: je dois fixer l'adresse ip ET installer le serveur DNS Bind qui va bien avec la bonne conf !!!

# virt-install --import --name centos7-dns \
--memory 1024 --vcpus 1 --cpu host \
--disk centos7-dns.qcow2,format=qcow2,bus=virtio \
--disk centos7-dns-cidata.iso,device=cdrom \
--network network=openshift-dns,model=virtio,mac=52:54:00:00:06:10 \
--os-type=linux \
--os-variant=centos7.0 \
--graphics spice \
--noautoconsole
# 
```



> Setup **libvert** to create a NAT network

**Current network interfaces**



#fais chier : je ne sais pas comment configurer le ha proxy pour l'adresse ip d'entrée !!!!








**NAT installation**

ou je ne peux ne pas en parler ...

TODO je vais devoir configurer un load balancer meme si je n'ai qu'un seul worker ou control plane ...
C'est pour le test

TODO reprendre un example d'installation openshift avec le même réseau, sous réseau !!! et mettre dans l'introduction les caracteristiques 

1. TODO
1. TOTO
