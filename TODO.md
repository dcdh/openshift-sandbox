yum install git vim telnet -y && yum update -y

Tester avec une adresse ip en 10.0.0.10 pour le host et 10.0.0.11 pour la machine virtuelle

- host:
sudo ip addr add 10.0.0.10/24 dev wlo1

Attention: linked with wlo1 so a connection with a router must be available !!! (TODO prerequists !!!)


- virtual machine
copy ifcfg-enp0s3:1 dans /etc/sysconfig/network-scripts/ifcfg-enp0s3:1
systemctl restart network
ip addr show | grep 10
ssh root@10.0.0.11


1. cela marche !!!!

installation openshift

Domain to use: (81.57.127.51.nip.io): 10.0.0.11
Username: (root): sandbox
Password: (password): sandbox
OpenShift Version: (3.11): 
IP: (192.168.0.22): 10.0.0.11
API Port: (8443):


Configuration host


echo "10.0.0.11       console.10.0.0.11       console.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       console.apps.10.0.0.11  console.apps.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       prometheus-k8s-openshift-monitoring.apps.10.0.0.11 prometheus-k8s-openshift-monitoring.apps.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       alertmanager-main-openshift-monitoring.apps.10.0.0.11 alertmanager-main-openshift-monitoring.apps.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       grafana-openshift-monitoring.apps.10.0.0.11 grafana-openshift-monitoring.apps.10.0.0.11" >> /etc/hosts




https://console.apps.10.0.0.11/ :)
