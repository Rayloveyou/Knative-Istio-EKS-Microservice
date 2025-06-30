#!/bin/bash
# Uninstall MySQL StatefulSet, Service, and delete persistent volumes

kubectl delete -f mysql.yaml
kubectl delete pvc -l app=mysql
kubectl delete pv -l app=mysql 