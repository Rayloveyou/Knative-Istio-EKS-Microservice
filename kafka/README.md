# Kafka Infrastructure

This directory contains the Kafka and Zookeeper deployment configurations using **Helm Chart** for the microservices architecture.

## 📋 Overview

Kafka is used as a message broker for event streaming and asynchronous communication between microservices. Zookeeper is required for Kafka coordination and metadata management.

## 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐
│  Zookeeper  │    │    Kafka    │
│   (Port     │    │   (Port     │
│    2181)    │    │    9092)    │
└─────────────┘    └─────────────┘
       │                   │
       └───────┬───────────┘
               │
    ┌──────────▼──────────┐
    │   Microservices     │
    │   (Producers &      │
    │    Consumers)       │
    └─────────────────────┘
```

## 📁 Files

- `kafka/` - **Helm Chart** directory containing all templates and configurations
- `kafka-values.yaml` - **Custom values** for Kafka Helm chart deployment
- `client.properties` - Kafka client configuration
- `deploy_kafka.sh` - Deployment script using Helm
- `README.md` - This documentation file

## 🚀 Quick Start

### Prerequisites

1. **Kubernetes cluster** with kubectl configured
2. **Helm** (>= 3.0) installed
3. **Storage class** available for persistent volumes

### Deployment

```bash
# Deploy Kafka and Zookeeper using Helm
./deploy_kafka.sh
```

### Manual Deployment

```bash
# Deploy using Helm chart with custom values
helm install kafka ./kafka -f kafka-values.yaml

# Wait for services to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=zookeeper --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kafka --timeout=300s
```

## 🔧 Configuration

### Helm Chart Configuration

The Kafka deployment uses a custom Helm chart with the following configuration:

- **Chart Version**: Based on Kafka 3.5.1
- **Zookeeper**: Embedded Zookeeper deployment
- **Kafka**: Single broker for development (scalable for production)
- **Storage**: Persistent volumes for data persistence
- **Security**: Basic authentication and authorization

### Key Configuration Files

#### `kafka-values.yaml`
```yaml
# Kafka configuration
kafka:
  replicas: 1
  persistence:
    enabled: true
    size: 5Gi
  
# Zookeeper configuration  
zookeeper:
  enabled: true
  persistence:
    enabled: true
    size: 1Gi
```

#### `client.properties`
```properties
bootstrap.servers=kafka:9092
security.protocol=PLAINTEXT
```

## 🌐 Accessing Kafka

### From within the cluster

```bash
# Kafka host: kafka
# Kafka port: 9092
# Zookeeper host: kafka-zookeeper
# Zookeeper port: 2181
```



### Using Kafka CLI tools

```bash
# Get Kafka pod name
KAFKA_POD=$(kubectl get pods -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}')

# List topics
kubectl exec -it $KAFKA_POD -- kafka-topics --list --bootstrap-server localhost:9092

# Create topic
kubectl exec -it $KAFKA_POD -- kafka-topics --create --topic test-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# Produce message
kubectl exec -it $KAFKA_POD -- kafka-console-producer --topic test-topic --bootstrap-server localhost:9092

# Consume messages
kubectl exec -it $KAFKA_POD -- kafka-console-consumer --topic test-topic --bootstrap-server localhost:9092 --from-beginning
```

## 📊 Monitoring

### Check Status

```bash
# Check Helm release
helm list

# Check pods
kubectl get pods -l app.kubernetes.io/name=kafka
kubectl get pods -l app.kubernetes.io/name=zookeeper

# Check services
kubectl get svc | grep -E '(kafka|zookeeper)'

# Check persistent volumes
kubectl get pvc
kubectl get pv
```

### View Logs

```bash
# Kafka logs
kubectl logs -l app.kubernetes.io/name=kafka

# Zookeeper logs
kubectl logs -l app.kubernetes.io/name=zookeeper
```

### Helm Status

```bash
# Check Helm release status
helm status kafka

# Get Helm values
helm get values kafka
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Helm installation fails

```bash
# Check Helm chart syntax
helm lint ./kafka

# Check values file
helm template kafka ./kafka -f kafka-values.yaml

# Check for conflicts
helm list | grep kafka
```

#### 2. Pods not starting

```bash
# Check pod events
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>

# Check Helm release events
helm get events kafka
```

#### 3. Storage issues

```bash
# Check persistent volume claims
kubectl get pvc

# Check persistent volumes
kubectl get pv

# Check storage class
kubectl get storageclass
```

#### 4. Kafka not connecting to Zookeeper

```bash
# Check if Zookeeper is ready
kubectl get pods -l app.kubernetes.io/name=zookeeper

# Check Zookeeper logs
kubectl logs -l app.kubernetes.io/name=zookeeper

# Test connectivity from Kafka pod
kubectl exec -it <kafka-pod> -- nc -zv kafka-zookeeper 2181
```

## 🧹 Cleanup

### Remove Kafka using Helm

```bash
# Uninstall Kafka Helm release
helm uninstall kafka

# Delete persistent volume claims
kubectl delete pvc --all
```

### Manual cleanup

```bash
# Delete all Kafka resources
kubectl delete all -l app.kubernetes.io/name=kafka
kubectl delete all -l app.kubernetes.io/name=zookeeper

# Delete persistent volumes
kubectl delete pvc --all
kubectl delete pv --all
```

## 📚 Additional Resources

- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [Zookeeper Documentation](https://zookeeper.apache.org/doc/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kafka Helm Chart](https://github.com/bitnami/charts/tree/main/bitnami/kafka)

## 🔗 Integration with Microservices

### Order Service Integration

The Order service uses Kafka for:
- Order event publishing
- Inventory updates
- Notification triggers

### Notification Service Integration

The Notification service uses Kafka for:
- Real-time event consumption
- WebSocket message distribution

### Configuration in Services

Services should be configured with:
```yaml
kafka:
  bootstrap-servers: kafka:9092
  zookeeper-servers: kafka-zookeeper:2181
  security:
    protocol: PLAINTEXT
```

### Example Spring Boot Configuration

```yaml
spring:
  kafka:
    bootstrap-servers: kafka:9092
    consumer:
      group-id: order-service
      auto-offset-reset: earliest
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
```

## 🚀 Production Considerations

### Scaling

```bash
# Scale Kafka to multiple replicas
helm upgrade kafka ./kafka -f kafka-values.yaml --set kafka.replicas=3
```

### High Availability

```bash
# Enable high availability
helm upgrade kafka ./kafka -f kafka-values.yaml \
  --set kafka.replicas=3 \
  --set zookeeper.replicas=3 \
  --set kafka.persistence.enabled=true \
  --set zookeeper.persistence.enabled=true
```

### Security

```bash
# Enable TLS encryption
helm upgrade kafka ./kafka -f kafka-values.yaml \
  --set kafka.auth.enabled=true \
  --set kafka.auth.tls.enabled=true
```

## 🚦 Deployment Flow

**Deploy Kafka after infrastructure is ready!**

1. Ensure EKS cluster is ready (see [terraform/README.md](../terraform/README.md))
2. Deploy Kafka & Zookeeper (this README)
3. Deploy other core services: [MySQL](../mysql/README.md), [Redis](../redis/README.md)
4. Deploy application layer:
   - [Traditional Kubernetes (Stateful)](../stateful/README.md)
   - [Knative + Istio](../knative/README.md)

## 📚 Related Documentation
- [Terraform README](../terraform/README.md)
- [MySQL README](../mysql/README.md)
- [Redis README](../redis/README.md)
- [Knative README](../knative/README.md)
- [Stateful README](../stateful/README.md)