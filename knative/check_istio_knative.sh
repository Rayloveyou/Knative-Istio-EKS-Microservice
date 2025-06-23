#!/bin/bash

echo "Checking Istio and Knative Integration..."

# Check if Istio is installed
echo "1. Checking Istio installation..."
if kubectl get namespace istio-system >/dev/null 2>&1; then
    echo "✅ Istio system namespace exists"
    
    # Check Istio pods
    echo "   Checking Istio pods..."
    kubectl get pods -n istio-system
    
    # Check Istio Gateway   
    echo "   Checking Istio Ingress Gateway..."
    kubectl get pods -n istio-system | grep ingressgateway
    
else
    echo "❌ Istio system namespace not found"
    echo "   Please install Istio first"
    exit 1
fi

echo ""
echo "2. Checking Knative Serving..."
if kubectl get namespace knative-serving >/dev/null 2>&1; then
    echo "✅ Knative Serving namespace exists"
    
    # Check Knative Serving pods
    echo "   Checking Knative Serving pods..."
    kubectl get pods -n knative-serving
    
else
    echo "❌ Knative Serving namespace not found"
    echo "   Please install Knative Serving first"
    exit 1
fi

echo ""
echo "3. Checking Knative-Istio integration..."
# Check if Knative is configured to use Istio
echo "   Checking Knative networking configuration..."
kubectl get configmap config-network -n knative-serving -o yaml | grep ingress-class

echo ""
echo "4. Checking Istio Gateway and VirtualServices..."
# Check if our Gateway and VirtualServices exist
if kubectl get gateway knative-gateway-simple >/dev/null 2>&1; then
    echo "✅ Istio Gateway exists"
else
    echo "⚠️  Istio Gateway not found"
fi

if kubectl get virtualservice >/dev/null 2>&1; then
    echo "✅ VirtualServices exist"
    kubectl get virtualservice
else
    echo "⚠️  No VirtualServices found"
fi

echo ""
echo "5. Testing service connectivity..."
# Test if we can reach the Istio Ingress Gateway
echo "   Getting Istio Ingress Gateway IP..."
INGRESS_IP=$(kubectl get service -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -n "$INGRESS_IP" ]; then
    echo "   Ingress Gateway IP: $INGRESS_IP"
    echo "   You can test connectivity with: curl -H 'Host: test.raydensolution.com' http://$INGRESS_IP"
else
    echo "   ⚠️  Ingress Gateway IP not available yet"
fi

echo ""
echo "6. Checking Knative services..."
kubectl get ksvc -n lab

echo ""
echo "Istio and Knative integration check completed!"
echo ""
echo "To test the setup:"
echo "1. Make sure your DNS points to the Istio Ingress Gateway IP"
echo "2. Test with: curl -H 'Host: test.raydensolution.com' http://$INGRESS_IP"
echo "3. Or add to /etc/hosts: $INGRESS_IP test.raydensolution.com api.raydensolution.com" 