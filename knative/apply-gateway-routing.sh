#!/bin/bash

# Script to apply Gateway and VirtualService configurations
# This sets up custom routing using our Gateway instead of Knative's default

set -e

echo "🚀 Applying Gateway and VirtualService Routing Configuration"
echo ""

# Apply Gateway configuration
echo "📡 Applying Gateway configuration..."
kubectl apply -f istio/gateway.yaml

# Apply VirtualService configurations
echo "🛣️  Applying VirtualService configurations..."
kubectl apply -f istio/virtual-services.yaml

echo ""
echo "✅ Gateway and VirtualService configurations applied!"

# Verify configurations
echo ""
echo "🔍 Verifying configurations..."

echo "📡 Gateway:"
kubectl get gateway knative-gateway -n lab -o yaml | grep -A 15 "spec:"

echo ""
echo "🛣️  VirtualServices:"
kubectl get virtualservice -n lab

echo ""
echo "🎯 Routing Configuration:"
echo "   - Gateway: lab/knative-gateway"
echo "   - Selector: istio: ingressgateway"
echo "   - Frontend: test.raydensolution.com → frontend-service"
echo "   - API Routes:"
echo "     * /ws → notification-service"
echo "     * /products → product-service"
echo "     * /orders → order-service"
echo "     * /auth → identity-service"
echo "     * /* → api-gateway (default)"

echo ""
echo "🔧 Next steps to complete the setup:"
echo "   1. Ensure Istio Ingress Gateway is running:"
echo "      kubectl get pods -n istio-system | grep ingressgateway"
echo ""
echo "   2. Get ALB DNS name:"
echo "      kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
echo "   3. Point your domains to the ALB DNS"
echo ""
echo "   4. Test routing:"
echo "      curl -H 'Host: test.raydensolution.com' http://YOUR_ALB_DNS"
echo "      curl -H 'Host: api.raydensolution.com' http://YOUR_ALB_DNS/products"
echo ""
echo "   5. Check Istio Ingress Gateway logs:"
echo "      kubectl logs -n istio-system deployment/istio-ingressgateway -f" 