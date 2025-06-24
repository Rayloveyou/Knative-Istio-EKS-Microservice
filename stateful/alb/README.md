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

## ℹ️ Note
- Đây là một trong hai phương án triển khai application (bên cạnh Istio/Knative). Bạn có thể chọn ALB hoặc Istio/Knative tuỳ theo nhu cầu. 