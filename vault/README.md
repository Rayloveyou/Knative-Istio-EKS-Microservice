# HashiCorp Vault Infrastructure

This directory contains the HashiCorp Vault deployment configuration using **Helm Chart** for secure secrets management in the microservices architecture on EKS.

## 📋 Overview

HashiCorp Vault is a powerful secrets management solution that provides centralized, secure storage and access to sensitive information such as:
- Database credentials
- API keys and tokens
- TLS certificates
- Application secrets
- Encryption keys
- Kubernetes service account tokens

## 🏗️ Architecture

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

## 📁 Directory Structure

```
vault/
├── README.md                 # This documentation
├── deploy_vault.sh          # Automated deployment script
├── uninstall_vault.sh       # Cleanup script
├── new-values.yaml          # Helm values configuration
├── vault-kv-policy.hcl      # Vault policy for KV access
├── cluster-keys.json        # Generated cluster keys (auto-created)
└── test/                    # Test configurations
    ├── sa.yaml             # Service account for testing
    └── test.yaml           # Test deployment with Vault agent
```

## 🚀 Quick Start

### Prerequisites

1. **EKS Cluster** with kubectl configured
2. **Helm** (>= 3.0) installed
3. **Storage class** available for persistent volumes
4. **ALB Controller** installed (for ingress)
5. **jq** installed for JSON parsing

### Automated Deployment

```bash
# Deploy Vault using the automated script
./deploy_vault.sh
```

The script will:
- Check prerequisites
- Add HashiCorp Helm repository
- Deploy Vault using Helm chart
- Initialize and unseal Vault
- Configure basic authentication

### Manual Deployment

```bash
# Add HashiCorp Helm repository
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Deploy Vault with custom values
helm install vault hashicorp/vault -f new-values.yaml

# Wait for Vault to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault --timeout=300s
```

## 🔧 Configuration

### Helm Chart Configuration

The Vault deployment uses the official HashiCorp Helm chart with the following key configurations:

- **Chart**: `hashicorp/vault`
- **Storage**: File storage backend (suitable for development/testing)
- **UI**: Enabled for web interface access
- **Ingress**: ALB Controller integration for external access
- **Security**: TLS disabled for development (enable for production)
- **Replicas**: Single instance for development

### Key Configuration Files

#### `new-values.yaml`
Main Helm values file containing:
- Vault server configuration
- Storage settings
- UI and ingress configuration
- Resource limits and requests
- Security settings

#### `vault-kv-policy.hcl`
Vault policy defining permissions:
```hcl
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/*" {
  capabilities = ["read", "list"]
}
```

## 🔐 Initialization and Setup

### 1. Initialize Vault

After deployment, Vault needs to be initialized:

```bash
# Initialize Vault (creates cluster-keys.json)
kubectl exec vault-0 -- vault operator init \
    -key-shares=1 \
    -key-threshold=1 \
    -format=json > cluster-keys.json
```

### 2. Unseal Vault

```bash
# Extract unseal key
VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")

# Unseal Vault
kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
```

### 3. Login and Configure

```bash
# Get root token
CLUSTER_ROOT_TOKEN=$(cat cluster-keys.json | jq -r ".root_token")

# Login to Vault
kubectl exec vault-0 -- vault login $CLUSTER_ROOT_TOKEN

# Enable KV secrets engine
kubectl exec vault-0 -- vault secrets enable kv

# Enable Kubernetes auth method
kubectl exec vault-0 -- vault auth enable kubernetes
```

### 4. Configure Kubernetes Authentication

```bash
# Get Kubernetes cluster information
KUBERNETES_HOST=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.server}')
KUBERNETES_CA_CERT=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode)

# Configure Kubernetes auth
kubectl exec vault-0 -- vault write auth/kubernetes/config \
    kubernetes_host="$KUBERNETES_HOST" \
    kubernetes_ca_cert="$KUBERNETES_CA_CERT" \
    token_reviewer_jwt="$(kubectl get secret $(kubectl get serviceaccount tinhbt -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 --decode)"
```

### 5. Create Policy and Role

```bash
# Create policy
kubectl exec vault-0 -- vault policy write tinhbt-kv-policy vault-kv-policy.hcl

# Create Kubernetes role
kubectl exec vault-0 -- vault write auth/kubernetes/role/nginx-role \
    bound_service_account_names=tinhbt \
    bound_service_account_namespaces=default \
    policies=tinhbt-kv-policy \
    ttl=1h
```

## 🧪 Testing the Setup

### 1. Create Test Service Account

```bash
kubectl apply -f test/sa.yaml
```

### 2. Deploy Test Application

```bash
kubectl apply -f test/test.yaml
```

The test deployment includes:
- Vault agent injection annotations
- Service account binding
- Secret mounting configuration

### 3. Verify Secret Injection

```bash
# Check if secrets are injected
kubectl exec deployment/tinhbt -- ls -la /vault/secrets/
kubectl exec deployment/tinhbt -- cat /vault/secrets/mysecret
```

## 🔍 Monitoring and Troubleshooting

### Check Vault Status

```bash
# Check Vault pod status
kubectl get pods -l app.kubernetes.io/name=vault

# Check Vault service
kubectl get svc | grep vault

# Check Vault logs
kubectl logs vault-0
```

### Access Vault UI

```bash
# Port forward to access Vault UI
kubectl port-forward vault-0 8200:8200
```

Then access: `http://localhost:8200`

### Common Issues

1. **Vault not unsealed**: Run unseal commands
2. **Authentication failures**: Check Kubernetes auth configuration
3. **Secret injection not working**: Verify annotations and service account

## 🧹 Cleanup

### Uninstall Vault

```bash
# Use the cleanup script
./uninstall_vault.sh
```

### Manual Cleanup

```bash
# Uninstall Helm release
helm uninstall vault

# Delete persistent volumes (if needed)
kubectl delete pvc -l app.kubernetes.io/name=vault
```

## 🔒 Security Considerations

### Production Recommendations

1. **Enable TLS**: Configure proper TLS certificates
2. **Use Auto-unseal**: Implement auto-unseal with AWS KMS or other cloud KMS
3. **Enable Audit Logging**: Configure audit devices
4. **Use Vault Agent**: Deploy Vault agent for better security
5. **Implement RBAC**: Use proper role-based access control
6. **Regular Key Rotation**: Implement key rotation policies

### Development vs Production

| Feature | Development | Production |
|---------|-------------|------------|
| TLS | Disabled | Enabled |
| Storage | File | Consul/Raft |
| Auto-unseal | Manual | AWS KMS |
| Audit Logging | Disabled | Enabled |
| Replicas | 1 | 3+ |

## 📚 Additional Resources

- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [Vault Helm Chart](https://github.com/hashicorp/vault-helm)
- [Kubernetes Auth Method](https://www.vaultproject.io/docs/auth/kubernetes)
- [Vault Agent](https://www.vaultproject.io/docs/agent)

## 🤝 Contributing

When making changes to the Vault configuration:

1. Update `new-values.yaml` for Helm configuration changes
2. Modify `vault-kv-policy.hcl` for policy changes
3. Update test configurations in `test/` directory
4. Update this README for any new procedures

---

**Note**: This setup is configured for development/testing environments. For production deployments, ensure proper security configurations are in place.




