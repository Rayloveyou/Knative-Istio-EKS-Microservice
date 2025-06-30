#!/bin/bash
# Uninstall Karpenter Helm release and optionally delete namespace

helm uninstall karpenter -n karpenter
kubectl delete namespace karpenter 