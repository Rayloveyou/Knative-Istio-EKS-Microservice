#!/bin/bash
# Uninstall Vault Helm release, delete persistent volumes, and ingress

helm uninstall vault
kubectl delete pvc --selector=app.kubernetes.io/name=vault
kubectl delete pv --selector=app.kubernetes.io/name=vault
kubectl delete ingress vault-ingres 