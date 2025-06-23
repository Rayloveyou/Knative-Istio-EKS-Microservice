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
│  │   Service   │ │   Service   │ │  Service    │ │  Service    │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ │
│  ┌─────────────┐ ┌─────────────┐                                │
│  │   Order     │ │Notification │                                │
│  │  Service    │ │  Service    │                                │
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

## 📁 Project Structure

```
.
├── README.md                    # This file - Project overview and structure
├── terraform/                   # Infrastructure as Code
│   ├── README.md               # Terraform documentation
│   ├── 0-providers.tf          # AWS provider configuration
│   ├── 1-vpc.tf                # VPC and networking setup
│   └── 2-eks.tf                # EKS cluster configuration
├── stateful/                   # Traditional Kubernetes deployment
│   ├── serivces/               # Application services
│   │   ├── api-gateway/        # API Gateway service
│   │   ├── frontend/           # Frontend application
│   │   ├── identity/           # Authentication service
│   │   ├── mysql/              # MySQL database
│   │   ├── notification/       # Notification service
│   │   ├── order/              # Order processing service
│   │   ├── product/            # Product management service
│   │   └── redis/              # Redis cache
│   ├── resources/              # Additional resources
│   │   ├── ing.yaml            # Ingress configuration
│   │   ├── setup-alb-controller.sh # ALB Controller setup
│   │   ├── iam_policy.json     # IAM policy for ALB Controller
│   │   └── vault/              # Vault configuration
│   ├── deploy_stateful.sh      # Traditional deployment script
│   └── cleanup_stateful.sh     # Traditional cleanup script
├── knative/                    # Knative + Istio deployment
│   ├── README.md               # Knative documentation
│   ├── deploy_knative.sh       # Knative deployment script
│   ├── cleanup_knative.sh      # Knative cleanup script
│   ├── check_knative.sh        # Health check script
│   ├── services/               # Knative service configurations
│   │   ├── api-gateway.yaml
│   │   ├── frontend-service.yaml
│   │   ├── identity-service.yaml
│   │   ├── notification-service.yaml
│   │   ├── order-service.yaml
│   │   └── product-service.yaml
│   └── istio/                  # Istio traffic management
│       ├── gateway.yaml        # Istio Gateway
│       └── virtual-services.yaml # Istio VirtualServices
├── kafka/                      # Kafka infrastructure (Helm Chart)
│   ├── README.md               # Kafka documentation
│   ├── deploy_kafka.sh         # Kafka deployment script
│   ├── kafka/                  # Helm chart directory
│   ├── kafka-values.yaml       # Helm values
│   └── client.properties       # Client configuration
└── vault/                      # Vault infrastructure
    ├── README.md               # Vault documentation
    ├── deploy_vault.sh         # Vault deployment script
    └── vault-ing.yaml          # Vault configuration
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** (>= 1.0)
3. **kubectl** (>= 1.24)
4. **helm** (>= 3.0)
5. **istioctl** (for Knative deployment)

### Step 1: Deploy Infrastructure

```bash
# Navigate to terraform directory
cd terraform

# Initialize and deploy infrastructure
terraform init
terraform plan
terraform apply

# Configure kubectl for the new cluster
aws eks update-kubeconfig --region us-east-1 --name datnghiem-eks

# Verify cluster access
kubectl cluster-info
```

### Step 2: Choose Deployment Approach

#### **Approach 1: Traditional Kubernetes Deployment**

```bash
# Deploy traditional services with ALB Controller
./deploy_stateful.sh
```

#### **Approach 2: Knative + Istio Deployment**

```bash
# Deploy Knative services with Istio
cd knative
./deploy_knative.sh
```

### Step 3: Deploy Infrastructure Services (Optional)

```bash
# Deploy Kafka (Helm Chart)
cd kafka
./deploy_kafka.sh

# Deploy Vault
cd ../vault
./deploy_vault.sh
```

## 🔧 Deployment Approaches

### **Traditional Kubernetes Deployment (`stateful/`)**

**Features:**
- ✅ Standard Kubernetes deployments and services
- ✅ ALB Controller for AWS Load Balancer integration
- ✅ Ingress-based routing
- ✅ Familiar Kubernetes concepts
- ✅ Easy to understand and debug

**Use Cases:**
- Learning and development
- Teams familiar with Kubernetes
- Simple microservices architecture
- Cost-effective for small to medium workloads

### **Knative + Istio Deployment (`knative/`)**

**Features:**
- ✅ Serverless auto-scaling (scale to zero)
- ✅ Advanced traffic management with Istio
- ✅ Blue-green deployments
- ✅ Service mesh capabilities
- ✅ Event-driven architecture

**Use Cases:**
- Production workloads with variable traffic
- Advanced traffic management requirements
- Serverless architecture goals
- Event-driven microservices

## 🌐 Service Architecture

### **Core Services**

| Service | Purpose | Port | Technology |
|---------|---------|------|------------|
| **Frontend** | Web application | 80 | Static web app |
| **API Gateway** | Main entry point | 8080 | Spring Boot |
| **Identity** | Authentication | 9898 | Spring Boot |
| **Product** | Product management | 8082 | Spring Boot |
| **Order** | Order processing | 8081 | Spring Boot |
| **Notification** | Real-time notifications | 8083 | Spring Boot + WebSocket |

### **Data Layer**

| Service | Purpose | Port | Storage |
|---------|---------|------|---------|
| **MySQL** | Primary database | 3306 | 1Gi persistent volume |
| **Redis** | Caching layer | 6379 | 1Gi persistent volume |

### **Infrastructure Services**

| Service | Purpose | Port | Technology |
|---------|---------|------|------------|
| **Kafka** | Message broker | 9092 | Helm Chart |
| **Vault** | Secrets management | 8200 | HashiCorp Vault |

## 🔐 Security Features

### **Network Security**
- Private subnets for worker nodes
- Security groups with minimal access
- NAT Gateway for outbound internet
- No direct internet access to pods

### **IAM Security**
- Least privilege access
- Proper IAM roles for EKS
- Service accounts for applications
- Encrypted secrets management

### **Application Security**
- Vault for secrets management
- TLS encryption for communications
- RBAC for Kubernetes resources
- Network policies for pod-to-pod communication

## 📊 Monitoring and Management

### **Health Checks**

```bash
# Traditional deployment
kubectl get pods
kubectl get services
kubectl get ingress

# Knative deployment
kubectl get ksvc
kubectl get gateway
kubectl get virtualservice
```

### **Logs and Debugging**

```bash
# View service logs
kubectl logs -l app=<service-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Monitor resources
kubectl top pods
kubectl top nodes
```

## 🧹 Cleanup

### **Application Cleanup**

```bash
# Traditional deployment cleanup
./cleanup_stateful.sh

# Knative deployment cleanup
./cleanup_knative.sh
```

### **Infrastructure Cleanup**

```bash
# Remove all infrastructure
cd terraform
terraform destroy
```

## 📚 Documentation

- **[Terraform README](terraform/README.md)** - Infrastructure setup and configuration
- **[Knative README](knative/README.md)** - Knative + Istio deployment guide
- **[Kafka README](kafka/README.md)** - Kafka Helm chart deployment
- **[Vault README](vault/README.md)** - Vault secrets management setup

## 🔗 Key Features

### **Infrastructure**
- ✅ **Terraform AWS Modules** for reliable infrastructure
- ✅ **Multi-AZ deployment** for high availability
- ✅ **Auto-scaling** node groups
- ✅ **EBS CSI Driver** for persistent storage
- ✅ **Karpenter-ready** configuration

### **Application**
- ✅ **Microservices architecture** with clear separation
- ✅ **Event-driven communication** with Kafka
- ✅ **Real-time notifications** with WebSocket
- ✅ **Authentication and authorization** service
- ✅ **API Gateway** pattern implementation

### **Operations**
- ✅ **Automated deployment** scripts
- ✅ **Health monitoring** and checks
- ✅ **Easy cleanup** procedures
- ✅ **Comprehensive documentation**
- ✅ **Production-ready** configurations

## 🚀 Next Steps

### **Development**
1. Customize service configurations
2. Add application-specific environment variables
3. Implement CI/CD pipelines
4. Add monitoring and alerting

### **Production**
1. Configure SSL certificates
2. Set up monitoring (Prometheus, Grafana)
3. Implement backup strategies
4. Configure disaster recovery
5. Set up logging (ELK stack)

### **Advanced Features**
1. Implement service mesh policies
2. Add distributed tracing
3. Configure advanced auto-scaling
4. Implement blue-green deployments
5. Add chaos engineering practices

## 📞 Support

For issues and questions:
1. Check the specific README files in each directory
2. Review Kubernetes, Knative, and Istio documentation
3. Check AWS EKS documentation
4. Verify Terraform configurations

## 📄 License

This project is provided as-is for educational and demonstration purposes. 