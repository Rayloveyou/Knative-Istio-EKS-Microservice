#!/bin/bash

# Vault Deployment Script for EKS using Helm Chart
# This script deploys HashiCorp Vault using Helm chart

echo "🔐 Deploying Vault on EKS using Helm Chart..."

# =============================================================================
# STEP 1: Check Prerequisites
# =============================================================================
echo "🔍 Checking prerequisites..."

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ helm is not installed"
    echo "Please install helm: https://helm.sh/docs/intro/install/"
    exit 1
fi

echo "✅ helm is installed"

# Check if kubectl is configured
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "❌ kubectl is not configured or cluster is not accessible"
    exit 1
fi

echo "✅ kubectl is configured"

# =============================================================================
# STEP 2: Add HashiCorp Helm Repository
# =============================================================================
echo "📚 Adding HashiCorp Helm repository..."

# Add HashiCorp Helm repository
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

echo "✅ HashiCorp repository added"

# =============================================================================
# STEP 3: Deploy Vault using Helm Chart
# =============================================================================
echo "📦 Deploying Vault using Helm Chart..."

# Check if Vault is already installed
if helm list | grep vault >/dev/null; then
    echo "   ✅ Vault already installed"
    echo "   📝 Upgrading Vault..."
    helm upgrade vault hashicorp/vault -f vault-values.yaml
else
    echo "   📦 Installing Vault..."
    helm install vault hashicorp/vault -f vault-values.yaml
fi

if [ $? -eq 0 ]; then
    echo "   ✅ Vault deployed successfully"
else
    echo "   ❌ Failed to deploy Vault"
    exit 1
fi

# =============================================================================
# STEP 4: Wait for Vault to be Ready
# =============================================================================
echo "⏳ Waiting for Vault to be ready..."

# Wait for Vault pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault --timeout=300s

if [ $? -eq 0 ]; then
    echo "   ✅ Vault is ready"
else
    echo "   ⚠️  Vault may still be starting up"
fi

# =============================================================================
# DEPLOYMENT COMPLETE - Display Information
# =============================================================================
echo ""
echo "🎉 Vault deployed successfully!"
echo ""
echo "📊 Service Status:"
echo "   helm list"
echo "   kubectl get pods -l app.kubernetes.io/name=vault"
echo ""
echo "🌐 Service URLs:"
echo "   kubectl get svc | grep vault"
echo "   kubectl get ingress | grep vault"
echo ""
echo "🔗 Vault Connection Details:"
echo "   • Vault Host: vault"
echo "   • Vault Port: 8200"
echo "   • Vault UI: http://vault.raydensolution.com"
echo ""
echo "📝 Next Steps:"
echo "   • Initialize Vault: kubectl exec -it <vault-pod> -- vault operator init"
echo "   • Unseal Vault: kubectl exec -it <vault-pod> -- vault operator unseal"
echo "   • Access Vault UI at http://vault.raydensolution.com"
echo "   • Deploy Knative services: cd ../knative && ./deploy_knative.sh" 