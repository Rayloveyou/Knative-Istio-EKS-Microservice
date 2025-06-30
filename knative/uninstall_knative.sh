#!/bin/bash
# Uninstall Knative services, gateway, and domain mapping

kubectl delete -f services/
kubectl delete -f istio/gateway.yaml
kubectl delete -f istio/virtual-services.yaml
kubectl delete -f domain-mapping.yaml 