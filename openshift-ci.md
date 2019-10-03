# CI

oc login -u system:admin

oc new-project ci --display-name='CI/CD' --description='CI/CD Components (Jenkins, Nexus, Pipeline)'

## Nexus

oc process -f ../templates/nexus3-persistent-template.yml | oc create -f - -n ci

oc set resources dc/nexus --limits=cpu=1,memory=1Gi --requests=cpu=200m,memory=1Gi -n ci

> add in /etc/hosts in the host 
192.168.56.101  nexus-ci.apps.192.168.56.101               nexus-ci.apps.192.168.56.101

## Jenkins

oc process -f ../templates/jenkins-build-config.yml | oc create -f - -n ci

oc new-app -e INSTALL_PLUGINS=ssh-agent:1.15 jenkins-persistent -l app=jenkins -p MEMORY_LIMIT=1Gi -n ci

> add in /etc/hosts in the host 
192.168.56.101  jenkins-ci.apps.192.168.56.101              jenkins-ci.apps.192.168.56.101
