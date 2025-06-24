# Istio-based Application Deployment Guide

## 🚦 Deployment Flow

**Deploy application after core services (Kafka, MySQL, Redis) are ready!**

1. Ensure EKS cluster and core services are ready ([terraform/README.md](../../terraform/README.md), [kafka/README.md](../../kafka/README.md), [mysql/README.md](../../mysql/README.md), [redis/README.md](../../redis/README.md))
2. Install Istio (see below)
3. Deploy application services (see ../services/)

## 📚 Related Documentation
- [Terraform README](../../terraform/README.md)
- [Kafka README](../../kafka/README.md)
- [MySQL README](../../mysql/README.md)
- [Redis README](../../redis/README.md)
- [Knative README](../../knative/README.md)

* Install Istioctl
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.15.1 sh -
mv istio-1.15.1/bin/istioctl /user/local/bin
istioctl version



* Install:
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

istioctl x precheck

helm install istio-base istio/base --namespace istio-system --version 1.18.2 --create-namespace --set profile=demo

helm install istiod istio/istiod --namespace istio-system --version 1.18.2 --wait --set profile=demo

Trước khi cài ingressgateway, add eks-node SG allow Inbound TCP 15017 from eks-cluster SG 
helm install istio-ingress istio/gateway --namespace istio-ingress --version 1.18.2 --create-namespace 



