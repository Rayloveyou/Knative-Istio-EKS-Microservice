#!/bin/bash
# Uninstall Redis StatefulSet, Service, and delete persistent volumes

kubectl delete -f redis.yaml
kubectl delete pvc -l app=redis
kubectl delete pv -l app=redis 