# ALB-based Application Deployment Guide

## 🚦 Deployment Flow

**Deploy application after core services (Kafka, MySQL, Redis) are ready!**

1. Ensure EKS cluster and core services are ready ([terraform/README.md](../../terraform/README.md), [kafka/README.md](../../kafka/README.md), [mysql/README.md](../../mysql/README.md), [redis/README.md](../../redis/README.md))
2. Install and configure AWS ALB Ingress Controller (see setup-alb-controller.sh)
3. Deploy application services (see ../services/)
4. Apply Ingress configuration (ing.yaml)

## 📚 Related Documentation
- [Terraform README](../../terraform/README.md)
- [Kafka README](../../kafka/README.md)
- [MySQL README](../../mysql/README.md)
- [Redis README](../../redis/README.md)
- [Knative README](../../knative/README.md)
- [Istio README](../istio/README.md)


## ℹ️ Install
- Get the Role Arn in Terraform created
- helm repo add eks https://aws.github.io/eks-charts
- helm repo update eks
- helm pull eks/aws-load-balancer-controller --version 1.13.0 --untar
- config:
serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations: 
    eks.amazonaws.com/role-arn: <arn>>
clusterName: <your-cluser-name>

## ℹ️ Note
- This is one method for deploying application (beside Istio/Knative). You can choose ALB or Istio/Knative. 