# Kafka

## Prerequisites

### Memory

You need at least 5g of ram.
If you do not provide enough ram OpenShift containers may be stop during kafka pods creations.

### CPU

At least 2 cpu should be presents. However some pods may be stuck in pending state because not enough millicpu are available.

### Namespace

In the following command the namespace "developement" is used. You are free to change it as you want to target a present namespace.

## Installation

> just run this command from the shell :)

oc apply -f https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.11.4/strimzi-cluster-operator-0.11.4.yaml -n developement && \
    oc adm policy add-cluster-role-to-user strimzi-cluster-operator-namespaced --serviceaccount strimzi-cluster-operator -n developement && \
    oc adm policy add-cluster-role-to-user strimzi-entity-operator --serviceaccount strimzi-cluster-operator -n developement && \
    oc adm policy add-cluster-role-to-user strimzi-topic-operator --serviceaccount strimzi-cluster-operator -n developement && \
    oc apply -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/0.11.4/examples/kafka/kafka-persistent-single.yaml -n developement

