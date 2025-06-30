#!/bin/bash
# Uninstall ALB-related resources (Ingress, services, deployments)

kubectl delete -f ing.yaml
kubectl delete -f ../services/
# Optionally uninstall ALB controller
# kubectl delete -f setup-alb-controller.sh 