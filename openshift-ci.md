# CI

oc login -u system:admin

oc new-project ci --display-name='CI/CD' --description='CI/CD Components (Jenkins, Nexus, Pipeline)'

## Nexus

oc process -f templates/nexus3-persistent-template.yml | oc create -f - -n ci

oc set resources dc/nexus --limits=cpu=1,memory=1Gi --requests=cpu=200m,memory=1Gi -n ci

> http://nexus-ci.apps.192.168.56.101.nip.io/

## Jenkins

oc new-app -e INSTALL_PLUGINS=ssh-agent:1.15 jenkins-persistent -l app=jenkins -p MEMORY_LIMIT=1Gi -n ci

> https://jenkins-ci.apps.192.168.56.101.nip.io/
