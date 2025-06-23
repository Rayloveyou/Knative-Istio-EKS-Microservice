# Istio + Knative Architecture

## 🏗️ **Kiến trúc tổng thể**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Internet      │    │   AWS ALB       │    │  Istio System   │    │   Lab Namespace │
│   (Users)       │◄──►│   (Load Balancer)│◄──►│  (istio-system) │◄──►│  (lab)          │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                       ┌───────────────────────────────┼───────────────────────────────┐
                       │                               │                               │
              ┌────────▼────────┐            ┌────────▼────────┐            ┌────────▼────────┐
              │   Istio         │            │   Istio         │            │   Knative       │
              │   Gateway       │            │   VirtualService│            │   Services      │
              │   (Entry Point) │            │   (Routing)     │            │   (Applications)│
              └─────────────────┘            └─────────────────┘            └─────────────────┘
```

## 🔄 **Flow chi tiết**

### **1. External Traffic Flow:**
```
Internet Request → AWS ALB → Istio Ingress Gateway → Istio Gateway → Istio VirtualService → Knative Service
```

### **2. Namespace Organization:**
- **`istio-system`**: Istio components (Ingress Gateway, Gateway, VirtualService)
- **`lab`**: Knative services (api-gateway, frontend, identity, etc.)

### **3. Component Details:**

#### **AWS ALB (Application Load Balancer)**
- **Namespace**: `istio-system`
- **Service**: `istio-ingressgateway`
- **Port**: 80
- **Type**: LoadBalancer
- **External IP**: `k8s-istiosys-istioing-xxx.elb.us-east-1.amazonaws.com`

#### **Istio Gateway**
- **Namespace**: `istio-system`
- **Name**: `knative-gateway`
- **Selector**: `istio: ingressgateway`
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Hosts**: `test.raydensolution.com`, `api.raydensolution.com`

#### **Istio VirtualService**
- **Namespace**: `istio-system`
- **Names**: `frontend-vs`, `api-vs`
- **Gateway**: `knative-gateway`
- **Routing Rules**:
  - `test.raydensolution.com` → `frontend-service.lab.svc.cluster.local`
  - `api.raydensolution.com/ws` → `notification-service.lab.svc.cluster.local`
  - `api.raydensolution.com/products` → `product-service.lab.svc.cluster.local`
  - `api.raydensolution.com/orders` → `order-service.lab.svc.cluster.local`
  - `api.raydensolution.com/auth` → `identity-service.lab.svc.cluster.local`
  - `api.raydensolution.com/*` → `api-gateway.lab.svc.cluster.local`

#### **Knative Services**
- **Namespace**: `lab`
- **Services**: api-gateway, frontend-service, identity-service, product-service, order-service, notification-service
- **Auto-scaling**: Scale to 0 when no traffic, scale up when needed

## 📋 **Deployment Order**

### **1. Prerequisites**
```bash
# Install Istio
istioctl install --set profile=demo -y

# Install Knative
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.12.0/serving-core.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.12.0/serving-hpa.yaml
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.12.0/net-istio.yaml
```

### **2. Deploy Istio Resources (istio-system namespace)**
```bash
# Deploy Gateway
kubectl apply -f istio/gateway.yaml

# Deploy VirtualServices
kubectl apply -f istio/virtual-services.yaml

# Deploy Ingress for Istio Gateway
kubectl apply -f istio/ingress-for-istio-gateway.yaml
```

### **3. Deploy Knative Services (lab namespace)**
```bash
# Create namespace
kubectl create namespace lab

# Deploy services
kubectl apply -f services/
```

## 🔍 **Troubleshooting**

### **Check Istio Components:**
```bash
# Check Istio services
kubectl get svc -n istio-system

# Check Istio Gateway
kubectl get gateway -n istio-system

# Check Istio VirtualService
kubectl get virtualservice -n istio-system

# Check Istio Ingress Gateway logs
kubectl logs -n istio-system deployment/istio-ingressgateway
```

### **Check Knative Services:**
```bash
# Check Knative services
kubectl get ksvc -n lab

# Check Knative pods
kubectl get pods -n lab

# Check service URLs
kubectl get ksvc -n lab -o jsonpath='{range .items[*]}{.metadata.name}: {.status.url}{"\n"}{end}'
```

### **Check ALB:**
```bash
# Check Ingress
kubectl get ingress -n istio-system

# Check ALB Controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

## 🌐 **Access URLs**

### **External URLs (after DNS configuration):**
- **Frontend**: `http://test.raydensolution.com`
- **API Gateway**: `http://api.raydensolution.com`
- **Products**: `http://api.raydensolution.com/products`
- **Orders**: `http://api.raydensolution.com/orders`
- **Auth**: `http://api.raydensolution.com/auth`
- **WebSocket**: `http://api.raydensolution.com/ws`

### **Internal URLs (for testing):**
```bash
# Port forward Istio Ingress Gateway
kubectl port-forward svc/istio-ingressgateway 8080:80 -n istio-system

# Test with curl
curl -H "Host: api.raydensolution.com" http://localhost:8080/
curl -H "Host: test.raydensolution.com" http://localhost:8080/
```

## 🎯 **Key Benefits**

1. **Separation of Concerns**: Istio components in `istio-system`, applications in `lab`
2. **Auto-scaling**: Knative services scale to 0 when not in use
3. **Traffic Management**: Istio provides advanced routing and load balancing
4. **Security**: Istio provides mTLS and policy enforcement
5. **Observability**: Istio provides metrics, logs, and traces 