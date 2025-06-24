# Knative + Istio Deployment Guide

## 🚦 Deployment Flow

**Deploy Knative after core services (Kafka, MySQL, Redis) are ready!**

1. Ensure EKS cluster and core services are ready ([terraform/README.md](../terraform/README.md), [kafka/README.md](../kafka/README.md), [mysql/README.md](../mysql/README.md), [redis/README.md](../redis/README.md))
2. Install Istio and Knative (see below)
3. Deploy application services (see services/)

## 📚 Related Documentation
- [Terraform README](../terraform/README.md)
- [Kafka README](../kafka/README.md)
- [MySQL README](../mysql/README.md)
- [Redis README](../redis/README.md)
- [Stateful README](../stateful/README.md)

# 🚀 Knative + Istio Deployment

istioctl install -y
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.18.0/net-istio.yaml

helm repo add knative-operator https://knative.github.io/operator
helm install knative-operator --create-namespace --namespace knative-operator knative-operator/knative-operator


* Use knative domain with ur prefix domain
kubectl edit configmap config-domain -n knative-serving

Edit the file to replace svc.cluster.local with the domain you want to use, then remove the _example key and save your changes. In this example, knative.dev is configured as the domain for all routes:


apiVersion: v1
data:
  knative.dev: ""
kind: ConfigMap
[...]


* Use custom domain 
 Check domain-mapping.yaml
 Point DNS to Istioingressgateway IP