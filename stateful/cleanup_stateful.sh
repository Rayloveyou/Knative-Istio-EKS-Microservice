#!/bin/bash

# Stateful Cleanup Script
# This script removes all resources deployed by the stateful deployment approach

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

# Function to confirm cleanup
confirm_cleanup() {
    echo ""
    print_warning "This will delete ALL resources from the stateful deployment:"
    echo "  - All deployments (api-gateway, frontend, identity, notification, order, product)"
    echo "  - All services"
    echo "  - All statefulsets (mysql, redis)"
    echo "  - All persistent volume claims"
    echo "  - All persistent volumes"
    echo "  - All ingress resources"
    echo ""
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleanup cancelled"
        exit 0
    fi
}

# Function to cleanup application services
cleanup_applications() {
    print_status "Cleaning up application services..."
    
    # Delete deployments
    print_status "Deleting deployments..."
    kubectl delete deployment api-gateway frontend identity notification order product --ignore-not-found=true
    
    # Delete services
    print_status "Deleting services..."
    kubectl delete service api-gateway-service frontend-service identity-service notification-service order-service product-service --ignore-not-found=true
    
    print_success "Application services cleaned up"
}

# Function to cleanup infrastructure services
cleanup_infrastructure() {
    print_status "Cleaning up infrastructure services..."
    
    # Delete statefulsets
    print_status "Deleting statefulsets..."
    kubectl delete statefulset mysql redis --ignore-not-found=true
    
    # Delete infrastructure services
    print_status "Deleting infrastructure services..."
    kubectl delete service mysql redis --ignore-not-found=true
    
    print_success "Infrastructure services cleaned up"
}

# Function to cleanup ingress
cleanup_ingress() {
    print_status "Cleaning up ingress resources..."
    
    # Delete ingress
    if [ -f "resources/ing.yaml" ]; then
        kubectl delete -f resources/ing.yaml --ignore-not-found=true
    else
        kubectl delete ingress microservices-ingress --ignore-not-found=true
    fi
    
    print_success "Ingress resources cleaned up"
}

# Function to cleanup persistent volumes
cleanup_storage() {
    print_status "Cleaning up persistent volumes..."
    
    # Delete persistent volume claims
    print_status "Deleting persistent volume claims..."
    kubectl delete pvc --all --ignore-not-found=true
    
    # Delete persistent volumes
    print_status "Deleting persistent volumes..."
    kubectl delete pv --all --ignore-not-found=true
    
    print_success "Storage resources cleaned up"
}

# Function to cleanup other resources
cleanup_other() {
    print_status "Cleaning up other resources..."
    
    # Delete any remaining pods
    print_status "Deleting any remaining pods..."
    kubectl delete pods --all --ignore-not-found=true
    
    # Delete any remaining services
    print_status "Deleting any remaining services..."
    kubectl delete service --all --ignore-not-found=true
    
    # Delete any remaining deployments
    print_status "Deleting any remaining deployments..."
    kubectl delete deployment --all --ignore-not-found=true
    
    # Delete any remaining statefulsets
    print_status "Deleting any remaining statefulsets..."
    kubectl delete statefulset --all --ignore-not-found=true
    
    print_success "Other resources cleaned up"
}

# Function to show cleanup status
show_status() {
    print_status "Cleanup Status:"
    echo ""
    
    print_status "Remaining pods:"
    kubectl get pods --ignore-not-found=true
    
    echo ""
    print_status "Remaining services:"
    kubectl get services --ignore-not-found=true
    
    echo ""
    print_status "Remaining deployments:"
    kubectl get deployments --ignore-not-found=true
    
    echo ""
    print_status "Remaining statefulsets:"
    kubectl get statefulsets --ignore-not-found=true
    
    echo ""
    print_status "Remaining persistent volume claims:"
    kubectl get pvc --ignore-not-found=true
    
    echo ""
    print_status "Remaining ingress:"
    kubectl get ingress --ignore-not-found=true
    
    echo ""
    print_success "Cleanup completed successfully!"
}

# Function to wait for resources to be deleted
wait_for_deletion() {
    local resource_type=$1
    local resource_name=$2
    local timeout=${3:-60}
    
    print_status "Waiting for $resource_type '$resource_name' to be deleted (timeout: ${timeout}s)"
    
    local count=0
    while [ $count -lt $timeout ]; do
        if ! kubectl get $resource_type $resource_name &> /dev/null; then
            print_success "$resource_type '$resource_name' deleted"
            return 0
        fi
        
        sleep 2
        count=$((count + 2))
    done
    
    print_warning "Timeout waiting for $resource_type '$resource_name' to be deleted"
    return 1
}

# Main cleanup function
main() {
    echo "=========================================="
    echo "    Stateful Microservices Cleanup        "
    echo "=========================================="
    echo ""
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_kubectl
    
    # Confirm cleanup
    confirm_cleanup
    
    # Cleanup in order
    cleanup_applications
    cleanup_infrastructure
    cleanup_ingress
    cleanup_storage
    cleanup_other
    
    # Show final status
    show_status
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h        Show this help message"
        echo "  --force, -f       Skip confirmation prompt"
        echo "  --apps-only       Cleanup only application services"
        echo "  --infra-only      Cleanup only infrastructure services"
        echo "  --storage-only    Cleanup only storage resources"
        echo "  --ingress-only    Cleanup only ingress resources"
        echo ""
        echo "Examples:"
        echo "  $0                # Cleanup everything with confirmation"
        echo "  $0 --force        # Cleanup everything without confirmation"
        echo "  $0 --apps-only    # Cleanup only application services"
        echo "  $0 --infra-only   # Cleanup only infrastructure services"
        exit 0
        ;;
    --force|-f)
        print_status "Force cleanup mode - skipping confirmation"
        check_kubectl
        cleanup_applications
        cleanup_infrastructure
        cleanup_ingress
        cleanup_storage
        cleanup_other
        show_status
        ;;
    --apps-only)
        print_status "Cleaning up application services only..."
        check_kubectl
        cleanup_applications
        show_status
        ;;
    --infra-only)
        print_status "Cleaning up infrastructure services only..."
        check_kubectl
        cleanup_infrastructure
        cleanup_storage
        show_status
        ;;
    --storage-only)
        print_status "Cleaning up storage resources only..."
        check_kubectl
        cleanup_storage
        show_status
        ;;
    --ingress-only)
        print_status "Cleaning up ingress resources only..."
        check_kubectl
        cleanup_ingress
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