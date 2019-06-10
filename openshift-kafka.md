
TODO faire un script avec la possibilité de définir une variable d'environnement pour sélectionner le namespace

oc apply -f https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.11.4/strimzi-cluster-operator-0.11.4.yaml -n developement

oc adm policy add-cluster-role-to-user strimzi-cluster-operator-namespaced --serviceaccount strimzi-cluster-operator -n developement
oc adm policy add-cluster-role-to-user strimzi-entity-operator --serviceaccount strimzi-cluster-operator -n developement
oc adm policy add-cluster-role-to-user strimzi-topic-operator --serviceaccount strimzi-cluster-operator -n developement

oc apply -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/0.11.4/examples/kafka/kafka-persistent-single.yaml -n developement
