#!/bin/bash

# Deploy Knative Microservices with Istio
# This script deploys all Knative services in the lab namespace

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

# Function to create namespace
create_namespace() {
    local namespace="lab"
    
    print_status "Creating namespace: $namespace"
    
    # Check if namespace already exists
    if kubectl get namespace $namespace &> /dev/null; then
        print_warning "Namespace $namespace already exists"
    else
        # Create namespace
        kubectl create namespace $namespace
        print_success "Namespace $namespace created successfully"
    fi
    
    # Add labels to namespace for better organization
    kubectl label namespace $namespace environment=lab --overwrite
    kubectl label namespace $namespace project=knative-microservices --overwrite
}

# Function to deploy stateful services
deploy_stateful_services() {
    print_status "Deploying stateful services..."
    
    # Deploy MySQL
    print_status "Deploying MySQL..."
    kubectl apply -f ../stateful/serivces/mysql/mysql.yaml -n lab
    kubectl wait --for=condition=ready pod -l app=mysql -n lab --timeout=300s
    print_success "MySQL deployed"
    
    # Deploy Redis
    print_status "Deploying Redis..."
    kubectl apply -f ../stateful/serivces/redis/redis.yaml -n lab
    kubectl wait --for=condition=ready pod -l app=redis -n lab --timeout=300s
    print_success "Redis deployed"
}

# Function to deploy Knative services
deploy_knative_services() {
    print_status "Deploying Knative services..."
    
    # Deploy all services at once
    kubectl apply -f services/
    print_success "All Knative services deployed"
}

# Function to deploy Istio resources
deploy_istio_resources() {
    print_status "Deploying Istio Gateway and VirtualServices..."
    
    # Deploy Gateway
    print_status "Deploying Istio Gateway..."
    kubectl apply -f istio/gateway.yaml
    print_success "Istio Gateway deployed"
    
    # Deploy VirtualServices
    print_status "Deploying Istio VirtualServices..."
    kubectl apply -f istio/virtual-services.yaml
    print_success "Istio VirtualServices deployed"
}

# Function to show deployment status
show_status() {
    print_status "Deployment Status:"
    echo ""
    
    print_status "Knative Services:"
    kubectl get ksvc -n lab
    
    echo ""
    print_status "Pods:"
    kubectl get pods -n lab
    
    echo ""
    print_status "Istio Components (lab namespace):"
    kubectl get gateway,virtualservice -n lab
    
    echo ""
    print_status "Istio Ingress Gateway LoadBalancer:"
    kubectl get svc istio-ingressgateway -n istio-system
}

# Function to show service URLs
show_urls() {
    print_status "Service URLs:"
    echo ""
    
    # Get service URLs
    FRONTEND_URL=$(kubectl get ksvc frontend-service -n lab -o jsonpath='{.status.url}' 2>/dev/null || echo "Not ready")
    API_GATEWAY_URL=$(kubectl get ksvc api-gateway -n lab -o jsonpath='{.status.url}' 2>/dev/null || echo "Not ready")
    
    echo "Frontend Service: $FRONTEND_URL"
    echo "API Gateway: $API_GATEWAY_URL"
    echo ""
    echo "External URLs (after DNS configuration):"
    echo "- Frontend: http://test.raydensolution.com"
    echo "- API Gateway: http://api.raydensolution.com"
    echo "- Products: http://api.raydensolution.com/products"
    echo "- Orders: http://api.raydensolution.com/orders"
    echo "- Auth: http://api.raydensolution.com/auth"
    echo "- WebSocket: http://api.raydensolution.com/ws"
}

# Function to get LoadBalancer DNS
get_lb_dns() {
    print_status "Getting LoadBalancer DNS name..."
    
    local lb_dns=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    
    if [ -n "$lb_dns" ]; then
        print_success "LoadBalancer DNS: $lb_dns"
        echo $lb_dns
    else
        print_warning "LoadBalancer DNS not available yet"
        return 1
    fi
}

# Main deployment function
main() {
    echo "=========================================="
    echo "    Deploying Knative Microservices      "
    echo "=========================================="
    echo ""
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_kubectl
    
    # Create namespace
    create_namespace
    
    # Deploy stateful services
    deploy_stateful_services
    
    # Deploy Istio resources first
    deploy_istio_resources
    
    # Deploy Knative services
    deploy_knative_services
    
    # Wait for resources to be ready
    print_status "Waiting for resources to be ready..."
    sleep 10
    
    # Show status
    show_status
    
    # Show URLs
    show_urls
    
    # Get LoadBalancer DNS
    local lb_dns=$(get_lb_dns)
    
    echo ""
    print_success "All services deployed successfully!"
    echo ""
    print_status "Next steps:"
    if [ -n "$lb_dns" ]; then
        echo "1. LoadBalancer DNS: $lb_dns"
        echo "2. Configure DNS to point to: $lb_dns"
        echo "3. Test: curl -H 'Host: test.raydensolution.com' http://$lb_dns/"
        echo "4. Test: curl -H 'Host: api.raydensolution.com' http://$lb_dns/"
    else
        echo "1. Wait for LoadBalancer to be created"
        echo "2. Get LoadBalancer DNS: kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
        echo "3. Configure DNS to point to the LoadBalancer DNS"
    fi
    echo "5. Monitor logs: kubectl logs -f deployment/istio-ingressgateway -n istio-system"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --services     Deploy only Knative services (skip stateful)"
        echo "  --istio        Deploy only Istio resources"
        echo ""
        echo "Examples:"
        echo "  $0              # Deploy everything"
        echo "  $0 --services   # Deploy only Knative services"
        echo "  $0 --istio      # Deploy only Istio resources"
        exit 0
        ;;
    --services)
        print_status "Deploying only Knative services..."
        check_kubectl
        create_namespace
        deploy_knative_services
        show_status
        show_urls
        ;;
    --istio)
        print_status "Deploying only Istio resources..."
        check_kubectl
        deploy_istio_resources
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