#!/bin/bash

# Stateful Deployment Script
# This script deploys the microservices using traditional Kubernetes deployments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    print_success "kubectl is available and connected to cluster"
}

# Function to wait for pods to be ready
wait_for_pods() {
    local namespace=$1
    local label_selector=$2
    local timeout=${3:-300}
    
    print_status "Waiting for pods with label $label_selector to be ready (timeout: ${timeout}s)"
    
    if kubectl wait --for=condition=ready pod -l $label_selector -n $namespace --timeout=${timeout}s; then
        print_success "All pods with label $label_selector are ready"
    else
        print_error "Timeout waiting for pods with label $label_selector"
        kubectl get pods -l $label_selector -n $namespace
        exit 1
    fi
}

# Function to deploy MySQL first
deploy_mysql() {
    print_status "Deploying MySQL (infrastructure service)..."
    kubectl apply -f mysql/mysql.yaml
    wait_for_pods "default" "app=mysql" 300
    print_success "MySQL deployed successfully"
}

# Function to deploy Redis
deploy_redis() {
    print_status "Deploying Redis..."
    kubectl apply -f redis/redis.yaml
    wait_for_pods "default" "app=redis" 300
    print_success "Redis deployed successfully"
}

# Function to deploy application services
deploy_applications() {
    print_status "Deploying application services..."
    
    # Deploy API Gateway
    print_status "Deploying API Gateway..."
    kubectl apply -f api-gateway/deployment.yaml
    
    # Deploy Frontend
    print_status "Deploying Frontend..."
    kubectl apply -f frontend/deployment.yaml
    
    # Deploy Identity Service
    print_status "Deploying Identity Service..."
    kubectl apply -f identity/deployment.yaml
    
    # Deploy Notification Service
    print_status "Deploying Notification Service..."
    kubectl apply -f notification/deployment.yaml
    
    # Deploy Order Service
    print_status "Deploying Order Service..."
    kubectl apply -f order/deployment.yaml
    
    # Deploy Product Service
    print_status "Deploying Product Service..."
    kubectl apply -f product/deployment.yaml
    
    # Wait for all application pods to be ready
    print_status "Waiting for application services to be ready..."
    wait_for_pods "default" "app=api-gateway" 180
    wait_for_pods "default" "app=frontend-service" 180
    wait_for_pods "default" "app=identity-service" 180
    wait_for_pods "default" "app=notification-service" 180
    wait_for_pods "default" "app=order-service" 180
    wait_for_pods "default" "app=product-service" 180
    
    print_success "Application services deployed successfully"
}

# Function to show deployment status
show_status() {
    print_status "Deployment Status:"
    echo ""
    
    print_status "Pods:"
    kubectl get pods
    
    echo ""
    print_status "Services:"
    kubectl get services
    
    echo ""
    print_status "StatefulSets:"
    kubectl get statefulsets
    
    echo ""
    print_status "Persistent Volume Claims:"
    kubectl get pvc
    
    echo ""
    print_status "Deployment completed successfully!"
}

# Main deployment function
main() {
    echo "=========================================="
    echo "    Stateful Microservices Deployment     "
    echo "=========================================="
    echo ""
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_kubectl
    
    # Deploy MySQL first
    deploy_mysql
    
    # Deploy Redis
    deploy_redis
    
    # Deploy application services
    deploy_applications
    
    # Show final status
    show_status
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --mysql-only   Deploy only MySQL"
        echo "  --redis-only   Deploy only Redis"
        echo "  --apps-only    Deploy only application services"
        echo ""
        echo "Examples:"
        echo "  $0              # Deploy everything"
        echo "  $0 --mysql-only # Deploy only MySQL"
        echo "  $0 --apps-only  # Deploy only application services"
        exit 0
        ;;
    --mysql-only)
        print_status "Deploying MySQL only..."
        check_kubectl
        deploy_mysql
        show_status
        ;;
    --redis-only)
        print_status "Deploying Redis only..."
        check_kubectl
        deploy_redis
        show_status
        ;;
    --apps-only)
        print_status "Deploying application services only..."
        check_kubectl
        deploy_applications
        show_status
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac 