# OpenShift Che

https://www.eclipse.org/che/docs/che-6/openshift-single-user.html#minishift-script

## Guest

ssh root@192.168.56.101

docker pull eclipse/che-server:nightly

curl -fsSL https://raw.githubusercontent.com/eclipse/che/master/deploy/openshift/deploy_che.sh -o deploy_che.sh

./deploy_che.sh


## Host

    echo "192.168.56.101  che-eclipse-che.apps.192.168.56.101       che-eclipse-che.apps.192.168.56.101" >> /etc/hosts
