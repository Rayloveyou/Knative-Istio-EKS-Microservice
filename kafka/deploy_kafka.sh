#!/bin/bash

# Kafka Deployment Script for EKS using Helm Chart
# This script deploys Kafka and Zookeeper using Helm chart

echo "📨 Deploying Kafka and Zookeeper on EKS using Helm Chart..."

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
# STEP 2: Deploy Kafka using Helm Chart
# =============================================================================
echo "📦 Deploying Kafka using Helm Chart..."

# Check if Kafka is already installed
if helm list | grep kafka >/dev/null; then
    echo "   ✅ Kafka already installed"
    echo "   📝 Upgrading Kafka..."
    helm upgrade kafka ./kafka -f kafka-values.yaml
else
    echo "   📦 Installing Kafka..."
    helm install kafka ./kafka -f kafka-values.yaml
fi

if [ $? -eq 0 ]; then
    echo "   ✅ Kafka deployed successfully"
else
    echo "   ❌ Failed to deploy Kafka"
    exit 1
fi

# =============================================================================
# STEP 3: Wait for Services to be Ready
# =============================================================================
echo "⏳ Waiting for Kafka services to be ready..."

# Wait for Zookeeper
echo "   🐘 Waiting for Zookeeper..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=zookeeper --timeout=300s

# Wait for Kafka
echo "   📨 Waiting for Kafka..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kafka --timeout=300s

echo "   ✅ All Kafka services are ready"

# =============================================================================
# DEPLOYMENT COMPLETE - Display Information
# =============================================================================
echo ""
echo "🎉 Kafka and Zookeeper deployed successfully!"
echo ""
echo "📊 Service Status:"
echo "   helm list"
echo "   kubectl get pods -l app.kubernetes.io/name=kafka"
echo "   kubectl get pods -l app.kubernetes.io/name=zookeeper"
echo ""
echo "🌐 Service URLs:"
echo "   kubectl get svc | grep -E '(kafka|zookeeper)'"
echo ""
echo "🔗 Kafka Connection Details:"
echo "   • Kafka Host: kafka"
echo "   • Kafka Port: 9092"
echo "   • Zookeeper Host: kafka-zookeeper"
echo "   • Zookeeper Port: 2181"
echo ""
echo "📝 Next Steps:"
echo "   • Deploy Knative services: cd ../knative && ./deploy_knative.sh"
echo "   • Test Kafka connectivity from your applications"
echo "   • Check Kafka topics: kubectl exec -it <kafka-pod> -- kafka-topics --list --bootstrap-server localhost:9092" 