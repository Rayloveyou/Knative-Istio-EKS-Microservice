# Knative-Istio-EKS-Microservice

A comprehensive microservices architecture deployed on Amazon EKS with support for both **Traditional Kubernetes** and **Knative + Istio** deployment approaches.

## 🏗️ Project Overview

This project demonstrates a complete microservices architecture with:
- **Infrastructure as Code** using Terraform AWS Modules
- **Two Deployment Approaches**: Traditional Kubernetes vs Knative + Istio
- **Event-Driven Architecture** with Kafka message broker
- **Secrets Management** with HashiCorp Vault
- **Auto-scaling** and **Load Balancing** capabilities
- **Production-ready** configuration with security best practices

## 🚦 Deployment Flow

1. **Initialize Infrastructure** ([terraform/README.md](terraform/README.md))
2. **Deploy Core Services**:
   - [Kafka](kafka/README.md)
   - [MySQL](mysql/README.md)
   - [Redis](redis/README.md)
3. **(Optional) Integrate**:
   - [Karpenter (autoscaling)](karpenter/README.md)
   - [Vault (secrets management)](vault/README.md)
4. **Deploy Application Layer**:
   - [Traditional Kubernetes (Stateful)](stateful/README.md) (ALB hoặc Istio)
   - [Knative + Istio](knative/README.md)

## 🔐 Vault Secrets Management

### Overview
HashiCorp Vault provides centralized secrets management for the microservices architecture, ensuring secure storage and access to sensitive information such as:
- Database credentials (MySQL, Redis)
- API keys and tokens
- TLS certificates
- Application secrets
- Kubernetes service account tokens

### Architecture Integration
```
┌─────────────────┐    ┌─────────────────┐
│   Vault Server  │    │  Microservices  │
│   (Port 8200)   │◄──►│   (API Clients) │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   KV Store  │ │    │ │   Vault     │ │
│ │   Secrets   │ │    │ │   Agent     │ │
│ └─────────────┘ │    │ └─────────────┘ │
│ ┌─────────────┐ │    └─────────────────┘
│ │ Kubernetes  │ │
│ │   Auth      │ │
│ └─────────────┘ │
└─────────────────┘
       │
       ▼
┌─────────────────┐
│  Persistent     │
│   Storage       │
│  (EBS Volume)   │
└─────────────────┘
```

### Quick Setup
```bash
# Navigate to Vault directory
cd vault

# Deploy Vault using automated script
./deploy_vault.sh

# Initialize and configure Vault
kubectl exec vault-0 -- vault operator init \
    -key-shares=1 \
    -key-threshold=1 \
    -format=json > cluster-keys.json

# Unseal Vault
VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY

# Login and enable secrets engine
CLUSTER_ROOT_TOKEN=$(cat cluster-keys.json | jq -r ".root_token")
kubectl exec vault-0 -- vault login $CLUSTER_ROOT_TOKEN
kubectl exec vault-0 -- vault secrets enable kv
```

### Integration with Microservices
Vault integrates with microservices through:
- **Kubernetes Authentication**: Service accounts authenticate with Vault
- **Vault Agent Injection**: Automatic secret injection into pods
- **KV Secrets Engine**: Key-value storage for application secrets
- **Policy-based Access Control**: Fine-grained permissions

### Security Features
- **Auto-unseal** (production): AWS KMS integration
- **Audit Logging**: Complete audit trail
- **TLS Encryption**: Secure communication
- **Token-based Authentication**: Time-limited access tokens
- **Role-based Access Control**: Granular permissions

For detailed setup and configuration, see [Vault README](vault/README.md).

## 🧩 Service Technology Stack

| Service              | Technology   |
|----------------------|-------------|
| **Frontend**         | HTML        |
| **API Gateway**      | Spring Boot |
| **Order Service**    | Spring Boot |
| **Identity Service** | Spring Boot |
| **Product Service**  | Spring Boot |
| **Notification**     | Spring Boot |
| **Kafka**            | Helm Chart  |
| **MySQL**            | Kubernetes YAML |
| **Redis**            | Kubernetes YAML |
| **Vault**            | Helm Chart  |

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS Infrastructure                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│  │   Terraform │ │     EKS     │ │    Kafka    │ │    Vault    │ │
│  │   (VPC +    │ │   Cluster   │ │   Message   │ │   Secrets   │ │
│  │   EKS)      │ │             │ │   Broker    │ │ Management  │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                    Application Layer                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│  │   Frontend  │ │ API Gateway │ │  Identity   │ │  Product    │ │
│  │   (HTML)    │ │ (SpringBoot)| │ (SpringBoot)| │ (SpringBoot)| │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ │
│  ┌─────────────┐ ┌─────────────┐                                │
│  │   Order     │ │Notification │                                │
│  │ (SpringBoot)| │ (SpringBoot)|                                │
│  └─────────────┘ └─────────────┘                                │ │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                    Data Layer                                   │
│  ┌─────────────┐ ┌─────────────┐                                │
│  │    MySQL    │ │    Redis    │                                │
│  │  Database   │ │    Cache    │                                │
│  └─────────────┘ └─────────────┘                                │
└─────────────────────────────────────────────────────────────────┘
```

## 📚 Documentation
- [Terraform README](terraform/README.md) - Infrastructure setup and configuration
- [Kafka README](kafka/README.md) - Kafka Helm chart deployment
- [MySQL README](mysql/README.md) - MySQL deployment
- [Redis README](redis/README.md) - Redis deployment
- [Karpenter README](karpenter/README.md) - Node autoscaling
- [Vault README](vault/README.md) - Vault secrets management setup
- [Knative README](knative/README.md) - Knative + Istio deployment guide
- [Stateful README](stateful/README.md) - Traditional Kubernetes deployment

## 🚀 Quick Start

### Prerequisites
- AWS CLI, Terraform, kubectl, helm, istioctl

### Step-by-step
1. **Infrastructure**: `cd terraform && terraform init && terraform apply`
2. **Core Services**: Deploy Kafka, MySQL, Redis
3. **(Optional)**: Deploy Karpenter, Vault
4. **Application**: Deploy via Stateful (ALB/Istio) hoặc Knative

## 🔗 Key Features
- IaC với Terraform
- Hai phương án triển khai: Stateful (ALB/Istio) hoặc Knative
- Kafka event-driven, Vault secrets, Karpenter autoscaling
- Microservices: Frontend (HTML), các service backend (Spring Boot)

## 📞 Support
- Xem README của từng folder hoặc liên hệ maintainer 