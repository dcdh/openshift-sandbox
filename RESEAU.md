ip route | grep default

si je fixe la route à 10.0.0.11
ping ne marche plus ...


route add default gw 10.0.0.11
route del -net 10.0.0.11

route del -net 0.0.0.0 gw 10.0.0.11 dev enp0route 
route del -net 0.0.0.0 gw 192.168.0.254 dev enp0s3


route add default gw 10.0.0.11



KO:
iptables -t nat -A POSTROUTING -o enp0s3 -j SNAT --to 192.168.0.254

KO:
iptables -t nat -A PREROUTING -i enp0s3 -j DNAT --to 192.168.0.254





// flush iptables

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT












# CONF

https://unix.stackexchange.com/questions/383791/virtualbox-host-only-with-internet


## virtual machine

echo "IPADDR=192.168.57.4/24" >> /etc/sysconfig/network-scripts/ifcfg-enp0s3
systemctl restart network


## host


sudo iptables -A FORWARD -o eth0 -i vboxnet1 -s 192.168.57.0/24 -m conntrack --ctstate NEW -j ACCEPT 
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A POSTROUTING -t nat -j MASQUERADE


putain ce n'est pas du 10.0.0.11 mais du localhost !!!

echo "10.0.0.11       console.10.0.0.11       console.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       console.apps.10.0.0.11  console.apps.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       prometheus-k8s-openshift-monitoring.apps.10.0.0.11 prometheus-k8s-openshift-monitoring.apps.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       alertmanager-main-openshift-monitoring.apps.10.0.0.11 alertmanager-main-openshift-monitoring.apps.10.0.0.11" >> /etc/hosts
echo "10.0.0.11       grafana-openshift-monitoring.apps.10.0.0.11 grafana-openshift-monitoring.apps.10.0.0.11" >> /etc/hosts

