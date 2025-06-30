#!/bin/bash
# Uninstall Kafka and Zookeeper Helm release and delete persistent volumes

helm uninstall kafka
kubectl delete pvc --selector=app.kubernetes.io/name=kafka
kubectl delete pvc --selector=app.kubernetes.io/name=zookeeper
kubectl delete pv --selector=app.kubernetes.io/name=kafka
kubectl delete pv --selector=app.kubernetes.io/name=zookeeper 