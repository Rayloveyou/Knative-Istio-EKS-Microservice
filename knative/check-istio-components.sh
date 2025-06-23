#!/bin/bash

# Check Istio Components Script
# This script shows the difference between Istio Ingress Gateway and Istio Gateway

set -e

echo "🔍 Checking Istio Components..."

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

# Function to check if namespace exists
check_namespace() {
    if kubectl get namespace $1 &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to show Istio Ingress Gateway (Service/Deployment)
show_istio_ingress_gateway() {
    echo ""
    print_status "=== Istio Ingress Gateway (Service/Deployment) ==="
    echo ""
    
    if check_namespace istio-system; then
        echo "📋 Istio Ingress Gateway Service:"
        kubectl get svc istio-ingressgateway -n istio-system -o wide
        
        echo ""
        echo "📋 Istio Ingress Gateway Deployment:"
        kubectl get deployment istio-ingressgateway -n istio-system
        
        echo ""
        echo "📋 Istio Ingress Gateway Pods:"
        kubectl get pods -n istio-system -l app=istio-ingressgateway
        
        echo ""
        echo "📋 Istio Ingress Gateway Service Details:"
        kubectl describe svc istio-ingressgateway -n istio-system | head -20
    else
        print_error "istio-system namespace not found"
    fi
}

# Function to show Istio Gateway (Custom Resource)
show_istio_gateway() {
    echo ""
    print_status "=== Istio Gateway (Custom Resource) ==="
    echo ""
    
    if check_namespace istio-system; then
        echo "📋 Istio Gateway Resources:"
        kubectl get gateway -n istio-system
        
        echo ""
        echo "📋 Istio Gateway Details:"
        kubectl get gateway knative-gateway -n istio-system -o yaml
    else
        print_error "istio-system namespace not found"
    fi
}

# Function to show VirtualServices
show_virtual_services() {
    echo ""
    print_status "=== Istio VirtualServices ==="
    echo ""
    
    if check_namespace istio-system; then
        echo "📋 VirtualService Resources:"
        kubectl get virtualservice -n istio-system
        
        echo ""
        echo "📋 VirtualService Details:"
        kubectl get virtualservice -n istio-system -o yaml
    else
        print_error "istio-system namespace not found"
    fi
}

# Function to show the relationship
show_relationship() {
    echo ""
    print_status "=== Mối quan hệ giữa Istio Ingress Gateway và Istio Gateway ==="
    echo ""
    
    echo "🔄 Flow:"
    echo "   External Traffic → Istio Ingress Gateway (Service) → Istio Gateway (Config) → VirtualService → Services"
    echo ""
    
    echo "📋 Istio Ingress Gateway (Service/Deployment):"
    echo "   - Type: Kubernetes Service"
    echo "   - Namespace: istio-system"
    echo "   - Chức năng: Proxy server nhận traffic"
    echo "   - Selector: app=istio-ingressgateway"
    echo ""
    
    echo "📋 Istio Gateway (Custom Resource):"
    echo "   - Type: Custom Resource (networking.istio.io/v1beta1)"
    echo "   - Namespace: istio-system"
    echo "   - Chức năng: Định nghĩa routing rules"
    echo "   - Selector: istio: ingressgateway (reference đến Istio Ingress Gateway)"
    echo ""
    
    echo "🔗 Connection:"
    echo "   - Istio Gateway selector 'istio: ingressgateway' reference đến Istio Ingress Gateway"
    echo "   - Cả hai phải cùng namespace để có thể reference"
    echo "   - Istio Ingress Gateway đọc config từ Istio Gateway và áp dụng routing"
}

# Function to show comparison table
show_comparison() {
    echo ""
    print_status "=== So sánh Istio Ingress Gateway vs Istio Gateway ==="
    echo ""
    
    printf "%-25s | %-25s | %-25s\n" "Aspect" "Istio Ingress Gateway" "Istio Gateway"
    printf "%-25s | %-25s | %-25s\n" "-------------------------" "-------------------------" "-------------------------"
    printf "%-25s | %-25s | %-25s\n" "Type" "Kubernetes Service" "Custom Resource"
    printf "%-25s | %-25s | %-25s\n" "Namespace" "istio-system" "istio-system"
    printf "%-25s | %-25s | %-25s\n" "Chức năng" "Proxy server" "Routing config"
    printf "%-25s | %-25s | %-25s\n" "Cấu hình" "Ports, protocols" "Hosts, routing rules"
    printf "%-25s | %-25s | %-25s\n" "Selector" "app=istio-ingressgateway" "istio: ingressgateway"
    printf "%-25s | %-25s | %-25s\n" "Routing" "Không có" "Có routing logic"
    printf "%-25s | %-25s | %-25s\n" "Host matching" "Không có" "Có host matching"
}

# Function to show troubleshooting
show_troubleshooting() {
    echo ""
    print_status "🔧 Troubleshooting Commands:"
    echo ""
    echo "Check Istio Ingress Gateway:"
    echo "  kubectl get svc -n istio-system | grep istio-ingressgateway"
    echo "  kubectl get pods -n istio-system -l app=istio-ingressgateway"
    echo "  kubectl logs -n istio-system deployment/istio-ingressgateway"
    echo ""
    echo "Check Istio Gateway:"
    echo "  kubectl get gateway -n istio-system"
    echo "  kubectl describe gateway knative-gateway -n istio-system"
    echo ""
    echo "Check VirtualServices:"
    echo "  kubectl get virtualservice -n istio-system"
    echo "  kubectl describe virtualservice -n istio-system"
    echo ""
    echo "Check Istio configuration:"
    echo "  istioctl analyze -n istio-system"
    echo "  istioctl proxy-config listeners -n istio-system deployment/istio-ingressgateway"
}

# Main execution
main() {
    print_status "Starting Istio components check..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    # Check if cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    # Show Istio Ingress Gateway
    show_istio_ingress_gateway
    
    # Show Istio Gateway
    show_istio_gateway
    
    # Show VirtualServices
    show_virtual_services
    
    # Show relationship
    show_relationship
    
    # Show comparison
    show_comparison
    
    # Show troubleshooting
    show_troubleshooting
    
    print_success "Istio components check completed!"
}

# Run main function
main "$@" 