#!/bin/bash

echo "Checking Knative installation..."

# Check if Knative Serving is installed
echo "1. Checking Knative Serving..."
if kubectl get namespace knative-serving >/dev/null 2>&1; then
    echo "✅ Knative Serving namespace exists"
    
    # Check Knative Serving pods
    echo "   Checking Knative Serving pods..."
    kubectl get pods -n knative-serving
    
    # Check Knative Serving CRDs
    echo "   Checking Knative Serving CRDs..."
    kubectl get crd | grep knative
    
else
    echo "❌ Knative Serving namespace not found"
    echo "   Please install Knative Serving first"
    exit 1
fi

echo ""
echo "2. Checking networking layer..."
# Check for Kourier
if kubectl get pods -n kourier-system >/dev/null 2>&1; then
    echo "✅ Kourier networking layer found"
    kubectl get pods -n kourier-system
else
    echo "⚠️  Kourier not found, checking for other networking layers..."
    kubectl get pods -A | grep -E "(istio|contour|ambassador)"
fi

echo ""
echo "3. Checking Knative configuration..."
# Check Knative config
kubectl get configmap -n knative-serving

echo ""
echo "4. Testing Knative installation..."
# Create a test service
cat <<EOF | kubectl apply -f -
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
spec:
  template:
    spec:
      containers:
      - image: gcr.io/knative-samples/helloworld-go
        ports:
        - containerPort: 8080
        env:
        - name: TARGET
          value: "World"
EOF

echo "   Created test service 'hello'"
echo "   Waiting for service to be ready..."

# Wait for service to be ready
kubectl wait --for=condition=ready ksvc/hello --timeout=60s

if [ $? -eq 0 ]; then
    echo "✅ Test service is ready"
    echo "   Service URL: $(kubectl get ksvc hello -o jsonpath='{.status.url}')"
    
    # Clean up test service
    kubectl delete ksvc hello
    echo "   Test service cleaned up"
else
    echo "❌ Test service failed to become ready"
    echo "   Check the service status: kubectl describe ksvc hello"
fi

echo ""
echo "Knative installation check completed!" 