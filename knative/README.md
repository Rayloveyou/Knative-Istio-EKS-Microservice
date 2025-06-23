# 🚀 Knative + Istio Deployment

## 📋 **Thành phần cần thiết:**

### **Namespace `istio-system`:**
- **Istio Ingress Gateway** (Service type LoadBalancer) - Tự động có khi install Istio
- **Istio Gateway** (Custom Resource) - Chúng ta tạo
- **Istio VirtualService** (Custom Resource) - Chúng ta tạo

### **Namespace `lab`:**
- **Knative Services** (api-gateway, frontend, identity, product, order, notification)
- **Stateful Services** (MySQL, Redis)

## 🔄 **Flow hoạt động:**

```
Internet → Istio Ingress Gateway (LoadBalancer) → Istio Gateway → VirtualService → Knative Services
```

## 🚀 **Deploy:**

### **Deploy tất cả:**
```bash
./deploy_knative.sh
```

### **Deploy chỉ Knative services:**
```bash
./deploy_knative.sh --services
```

### **Deploy chỉ Istio resources:**
```bash
./deploy_knative.sh --istio
```

## 🌐 **Lấy LoadBalancer DNS:**

```bash
./get-lb-dns.sh
```

Hoặc:
```bash
kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## 📝 **Cấu hình DNS:**

Trỏ domain đến LoadBalancer DNS:
- `test.raydensolution.com` → LoadBalancer DNS
- `api.raydensolution.com` → LoadBalancer DNS

## 🧪 **Test:**

```bash
# Test với LoadBalancer DNS
curl -H "Host: test.raydensolution.com" http://<LB-DNS>/
curl -H "Host: api.raydensolution.com" http://<LB-DNS>/
```

## 🔍 **Kiểm tra status:**

```bash
# Check Istio components
kubectl get gateway,virtualservice -n istio-system

# Check Knative services
kubectl get ksvc -n lab

# Check LoadBalancer
kubectl get svc istio-ingressgateway -n istio-system
```

## 🎯 **Tóm tắt:**

1. **Istio Ingress Gateway** đã có LoadBalancer sẵn
2. **Chỉ cần** Gateway và VirtualService để route
3. **Không cần** thêm Kubernetes Ingress
4. **Domain** trỏ trực tiếp đến LoadBalancer DNS

**Đơn giản và hiệu quả!** 🎉 