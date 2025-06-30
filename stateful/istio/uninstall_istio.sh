#!/bin/bash
# Uninstall Istio-related resources (Gateway, VirtualService, services)

kubectl delete -f gateway.yaml
kubectl delete -f virtual-services.yaml
kubectl delete -f ../services/ 