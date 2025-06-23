#!/bin/bash

# ALB Controller Setup Script for EKS
# This script sets up AWS Load Balancer Controller for EKS cluster

echo "🌐 Setting up AWS Load Balancer Controller for EKS..."

# =============================================================================
# STEP 1: Create IAM Policy
# =============================================================================
echo "📋 Creating IAM Policy..."

# Check if policy already exists
POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`AWSLoadBalancerControllerIAMPolicy`].Arn' --output text)

if [ -n "$POLICY_ARN" ] && [ "$POLICY_ARN" != "None" ]; then
    echo "   ✅ IAM Policy already exists: $POLICY_ARN"
else
    echo "   📝 Creating IAM Policy..."
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json
    
    if [ $? -eq 0 ]; then
        echo "   ✅ IAM Policy created successfully"
    else
        echo "   ❌ Failed to create IAM Policy"
        exit 1
    fi
fi

# =============================================================================
# STEP 2: Get Cluster Information
# =============================================================================
echo "🔍 Getting cluster information..."

# Get cluster name from kubectl context
CLUSTER_NAME=$(kubectl config current-context | sed 's/.*@//')

if [ -z "$CLUSTER_NAME" ]; then
    echo "   ❌ Could not determine cluster name from kubectl context"
    echo "   Please ensure kubectl is configured for your EKS cluster"
    exit 1
fi

echo "   ✅ Cluster name: $CLUSTER_NAME"

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "   ✅ AWS Account ID: $ACCOUNT_ID"

# =============================================================================
# STEP 3: Create IAM Service Account
# =============================================================================
echo "👤 Creating IAM Service Account..."

# Check if service account already exists
if kubectl get serviceaccount aws-load-balancer-controller -n kube-system >/dev/null 2>&1; then
    echo "   ✅ Service account already exists"
else
    echo "   📝 Creating service account with IAM role..."
    
    # Create service account with IAM role
    eksctl create iamserviceaccount \
        --cluster=$CLUSTER_NAME \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
        --approve
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Service account created successfully"
    else
        echo "   ❌ Failed to create service account"
        exit 1
    fi
fi

# =============================================================================
# STEP 4: Install ALB Controller with Helm
# =============================================================================
echo "📦 Installing ALB Controller with Helm..."

# Add EKS Helm repository
echo "   📚 Adding EKS Helm repository..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Check if ALB Controller is already installed
if helm list -n kube-system | grep aws-load-balancer-controller >/dev/null; then
    echo "   ✅ ALB Controller already installed"
    echo "   📝 Upgrading ALB Controller..."
    helm upgrade aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER_NAME \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
else
    echo "   📦 Installing ALB Controller..."
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER_NAME \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
fi

if [ $? -eq 0 ]; then
    echo "   ✅ ALB Controller installed successfully"
else
    echo "   ❌ Failed to install ALB Controller"
    exit 1
fi

# =============================================================================
# STEP 5: Verify Installation
# =============================================================================
echo "🔍 Verifying installation..."

# Wait for ALB Controller to be ready
echo "   ⏳ Waiting for ALB Controller to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=aws-load-balancer-controller -n kube-system --timeout=300s

if [ $? -eq 0 ]; then
    echo "   ✅ ALB Controller is ready"
else
    echo "   ⚠️  ALB Controller may still be starting up"
fi

# Check ALB Controller status
echo "   📊 ALB Controller status:"
kubectl get pods -n kube-system | grep aws-load-balancer-controller

# =============================================================================
# SETUP COMPLETE
# =============================================================================
echo ""
echo "🎉 ALB Controller setup completed successfully!"
echo ""
echo "📊 Verification Commands:"
echo "   kubectl get pods -n kube-system | grep aws-load-balancer-controller"
echo "   kubectl logs -n kube-system deployment/aws-load-balancer-controller"
echo ""
echo "🔗 Next Steps:"
echo "   • Deploy traditional services: kubectl apply -f stateful/serivces/"
echo "   • Deploy Knative services: cd knative && ./deploy_knative.sh"
echo ""
echo "📝 Notes:"
echo "   • ALB Controller will automatically create Load Balancers when you create Ingress resources"
echo "   • Make sure your Ingress resources use the 'alb' ingress class"
echo "   • The controller will handle the creation and management of AWS Application Load Balancers" 