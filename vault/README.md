# Vault Infrastructure

This directory contains the HashiCorp Vault deployment configuration using **Helm Chart** for secure secrets management in the microservices architecture.

## 📋 Overview

Vault is used for centralized secrets management, providing secure storage and access to sensitive information such as:
- Database credentials
- API keys
- TLS certificates
- Application secrets
- Encryption keys

## 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐
│    Vault    │    │Microservices│
│   (Port     │◄──►│   (API      │
│    8200)    │    │  Clients)   │
└─────────────┘    └─────────────┘
       │
       ▼
┌─────────────┐
│  Persistent │
│   Storage   │
└─────────────┘
```

## 📁 Files

- `vault-values.yaml` - **Helm values** for Vault deployment
- `vault-ing.yaml` - **Ingress configuration** for external access
- `deploy_vault.sh` - Deployment script using Helm
- `README.md` - This documentation file

## 🚀 Quick Start

### Prerequisites

1. **Kubernetes cluster** with kubectl configured
2. **Helm** (>= 3.0) installed
3. **Storage class** available for persistent volumes
4. **ALB Controller** installed (for ingress)

### Deployment

```bash
# Deploy Vault using Helm
./deploy_vault.sh
```

### Manual Deployment

```bash
# Add HashiCorp Helm repository
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Deploy Vault with custom values
helm install vault hashicorp/vault -f vault-values.yaml

# Wait for Vault to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault --timeout=300s
```

## 🔧 Configuration

### Helm Chart Configuration

The Vault deployment uses the official HashiCorp Helm chart with the following configuration:

- **Chart**: `hashicorp/vault`
- **Storage**: File storage backend (for development)
- **UI**: Enabled for web interface
- **Ingress**: ALB Controller integration
- **Security**: TLS disabled for development

### Key Configuration Files

#### `vault-values.yaml`
```yaml
# Vault server configuration
server:
  enabled: true
  replicas: 1
  ingress:
    enabled: true
    className: alb
    hosts:
      - host: vault.raydensolution.com
```

#### `vault-ing.yaml`
```yaml
# Ingress configuration for external access
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: vault-ingres
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
```

## 🌐 Accessing Vault

### From within the cluster

```bash
# Vault host: vault
# Vault port: 8200
# Vault UI: http://vault:8200/ui
```

### From outside the cluster

```bash
# Port forward Vault
kubectl port-forward service/vault 8200:8200

# Access Vault UI
open http://localhost:8200/ui
```

### External access via Ingress

```bash
# Access via domain
open http://vault.raydensolution.com
```

## 🔐 Initial Setup

### 1. Initialize Vault

```bash
# Get Vault pod name
VAULT_POD=$(kubectl get pods -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}')

# Initialize Vault
kubectl exec -it $VAULT_POD -- vault operator init

# This will output 5 unseal keys and a root token
# Save these securely!
```

### 2. Unseal Vault

```bash
# Unseal Vault (requires 3 of 5 keys)
kubectl exec -it $VAULT_POD -- vault operator unseal <key1>
kubectl exec -it $VAULT_POD -- vault operator unseal <key2>
kubectl exec -it $VAULT_POD -- vault operator unseal <key3>
```

### 3. Login to Vault

```bash
# Login with root token
kubectl exec -it $VAULT_POD -- vault login <root-token>
```

## 🔧 Vault Configuration

### Enable Secret Engines

```bash
# Enable key-value secrets engine
kubectl exec -it $VAULT_POD -- vault secrets enable -path=secret kv-v2

# Enable database secrets engine
kubectl exec -it $VAULT_POD -- vault secrets enable database
```

### Create Policies

```bash
# Create policy for application access
kubectl exec -it $VAULT_POD -- vault policy write app-policy - <<EOF
path "secret/data/*" {
  capabilities = ["read"]
}

path "database/creds/*" {
  capabilities = ["read"]
}
EOF
```

### Create AppRole

```bash
# Enable AppRole auth method
kubectl exec -it $VAULT_POD -- vault auth enable approle

# Create AppRole for applications
kubectl exec -it $VAULT_POD -- vault write auth/approle/role/app-role \
    token_policies="app-policy" \
    token_ttl=1h \
    token_max_ttl=4h
```

## 📊 Monitoring

### Check Status

```bash
# Check Vault pod
kubectl get pods -l app.kubernetes.io/name=vault

# Check Vault service
kubectl get svc | grep vault

# Check Vault ingress
kubectl get ingress | grep vault

# Check persistent volumes
kubectl get pvc
kubectl get pv
```

### View Logs

```bash
# Vault logs
kubectl logs -l app.kubernetes.io/name=vault
```

### Check Vault Status

```bash
# Get Vault pod name
VAULT_POD=$(kubectl get pods -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}')

# Check Vault status
kubectl exec -it $VAULT_POD -- vault status
```

### Helm Status

```bash
# Check Helm release status
helm status vault

# Get Helm values
helm get values vault
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Vault not starting

```bash
# Check pod events
kubectl describe pod <vault-pod>

# Check pod logs
kubectl logs <vault-pod>

# Check Helm release events
helm get events vault
```

#### 2. Storage issues

```bash
# Check persistent volume claims
kubectl get pvc

# Check persistent volumes
kubectl get pv

# Check storage class
kubectl get storageclass
```

#### 3. Vault sealed

```bash
# Check Vault status
kubectl exec -it <vault-pod> -- vault status

# If sealed, unseal with keys
kubectl exec -it <vault-pod> -- vault operator unseal <key>
```

#### 4. Ingress issues

```bash
# Check ingress status
kubectl describe ingress vault-ingres

# Check ALB Controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

## 🧹 Cleanup

### Remove Vault using Helm

```bash
# Uninstall Vault Helm release
helm uninstall vault

# Delete persistent volume claims
kubectl delete pvc --all
```

### Manual cleanup

```bash
# Delete all Vault resources
kubectl delete all -l app.kubernetes.io/name=vault

# Delete ingress
kubectl delete ingress vault-ingres

# Delete persistent volumes
kubectl delete pvc --all
kubectl delete pv --all
```

## 📚 Additional Resources

- [Vault Documentation](https://www.vaultproject.io/docs/)
- [Vault Kubernetes Integration](https://www.vaultproject.io/docs/platform/k8s)
- [Vault AppRole Auth Method](https://www.vaultproject.io/docs/auth/approle)
- [Vault Database Secrets Engine](https://www.vaultproject.io/docs/secrets/databases)
- [Vault Helm Chart](https://github.com/hashicorp/vault-helm)

## 🔗 Integration with Microservices

### Service Configuration

Services should be configured to use Vault for secrets:

```yaml
vault:
  address: http://vault:8200
  auth:
    method: approle
    role-id: <role-id>
    secret-id: <secret-id>
  secrets:
    database: database/creds/mysql-role
    api-keys: secret/data/api-keys
```

### Example: MySQL Credentials

```bash
# Configure MySQL database connection
kubectl exec -it $VAULT_POD -- vault write database/config/mysql \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(mysql:3306)/" \
    allowed_roles="mysql-role"

# Create MySQL role
kubectl exec -it $VAULT_POD -- vault write database/roles/mysql-role \
    db_name=mysql \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"
```

## 🔐 Security Best Practices

### Production Considerations

1. **High Availability**: Use multiple Vault instances with auto-unseal
2. **Storage Backend**: Use distributed storage (Consul, etcd)
3. **Authentication**: Use Kubernetes service accounts or AppRole
4. **Encryption**: Enable TLS for all communications
5. **Audit Logging**: Enable audit logging for compliance
6. **Backup**: Regular backup of Vault data and configuration
7. **Monitoring**: Monitor Vault health and performance
8. **Access Control**: Implement least privilege access policies

### Key Management

1. **Unseal Keys**: Store unseal keys securely (HSM, cloud KMS)
2. **Root Token**: Use root token only for initial setup
3. **Token Policies**: Create specific policies for each application
4. **Token TTL**: Set appropriate token time-to-live values
5. **Key Rotation**: Regular rotation of secrets and keys