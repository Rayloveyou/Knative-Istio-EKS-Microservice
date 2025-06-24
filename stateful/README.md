# Traditional Kubernetes (Stateful) Deployment Guide

## 🏗️ Overview

Thư mục này chứa các cấu hình triển khai application dạng truyền thống (Kubernetes Stateful), với hai phương án routing:
- **ALB (AWS Application Load Balancer)**
- **Istio (Service Mesh)**

## 🚦 Deployment Flow

1. Đảm bảo hạ tầng và các service core đã sẵn sàng ([terraform/README.md](../terraform/README.md), [kafka/README.md](../kafka/README.md), [mysql/README.md](../mysql/README.md), [redis/README.md](../redis/README.md))
2. Chọn một trong hai phương án routing:
   - [Triển khai với ALB](alb/README.md)
   - [Triển khai với Istio](istio/README.md)
3. Deploy các application service (xem [services/](services/))

## 📚 Related Documentation
- [Terraform README](../terraform/README.md)
- [Kafka README](../kafka/README.md)
- [MySQL README](../mysql/README.md)
- [Redis README](../redis/README.md)
- [Knative README](../knative/README.md)
- [ALB README](alb/README.md)
- [Istio README](istio/README.md)
- [Services](services/)

## Tổng quan luồng triển khai

1. **Triển khai các dịch vụ stateful (MySQL, Redis, Kafka, Zookeeper,...)**
2. **Triển khai các microservices ứng dụng (API Gateway, Frontend, Identity, Notification, Order, Product)**
3. **Expose hệ thống ra ngoài bằng 1 trong 2 cách:**
   - **Cách 1:** Sử dụng AWS ALB Ingress Controller
   - **Cách 2:** Sử dụng Istio Gateway + VirtualService

---

## 1. Chuẩn bị

- Đảm bảo đã cài đặt `kubectl` và kết nối tới cluster Kubernetes.
- Đảm bảo đã cài đặt Helm (nếu dùng Istio).
- Đảm bảo đã có quyền truy cập AWS (nếu dùng ALB).
- Các file cấu hình đã được chuẩn bị sẵn trong các thư mục con.

---

## 2. Triển khai dịch vụ stateful & ứng dụng

Chạy script sau để triển khai toàn bộ dịch vụ:

```bash
cd serivces
./deploy_services.sh
```

- Script sẽ tự động deploy MySQL, Redis, và các microservice ứng dụng.
- Có thể deploy từng phần riêng lẻ với các flag: `--mysql-only`, `--redis-only`, `--apps-only`.

### **Lưu ý sau khi triển khai MySQL:**

Sau khi MySQL pod đã chạy, cần exec vào pod và nhập dữ liệu phân quyền truy cập:

```bash
kubectl get pods | grep mysql
kubectl exec -it <mysql-pod-name> -- bash
mysql -u root -p
```

Sau đó, chọn database `javatechie` và copy nội dung trong file `serivces/mysql/url_access.sql` vào MySQL shell:

```sql
USE javatechie;
-- Copy nội dung file url_access.sql vào đây, ví dụ:
INSERT INTO url_access (role, url)
    SELECT 'ALLOW_URL', '/auth,/ws'
        WHERE NOT EXISTS (SELECT 1 FROM url_access WHERE role = 'ALLOW_URL');
INSERT INTO url_access (role, url)
    SELECT 'ADMIN', '/users,/product,/orders'
        WHERE NOT EXISTS (SELECT 1 FROM url_access WHERE role = 'ADMIN');
INSERT INTO url_access (role, url)
    SELECT 'USER', '/orders,/product'
        WHERE NOT EXISTS (SELECT 1 FROM url_access WHERE role = 'USER');
```

---

## 3. Expose hệ thống ra ngoài

### Cách 1: Sử dụng AWS ALB Ingress Controller

**Luồng triển khai:**
1. Cài đặt ALB Ingress Controller (nếu chưa có).
2. Tạo IAM policy và service account cho ALB Controller (file: `alb/iam_policy.json`, script: `alb/setup-alb-controller.sh`).
3. Áp dụng manifest Ingress để expose service (file: `alb/ing.yaml`).

**Các bước thực hiện:**

```bash
# 1. Tạo IAM policy và service account cho ALB Controller
cd alb
./setup-alb-controller.sh

# 2. Áp dụng manifest Ingress
kubectl apply -f ing.yaml
```

- Sau khi apply, ALB sẽ tự động tạo Load Balancer và route traffic tới các service backend.
- Kiểm tra địa chỉ ALB bằng lệnh:
  ```bash
  kubectl get ingress
  ```
- Truy cập hệ thống qua DNS của ALB.

---

### Cách 2: Sử dụng Istio Gateway

**Lưu ý:**
- Hướng dẫn cài đặt và cấu hình Istio chi tiết đã có trong file `istio/README.md`.
- Sau khi cài đặt xong Istio, thực hiện các bước sau để expose service:

```bash
cd istio
kubectl apply -f gateway.yaml
kubectl apply -f virtual-services.yaml
```

- Kiểm tra địa chỉ EXTERNAL-IP:
  ```bash
  kubectl get svc -n istio-ingress
  ```
- Trỏ DNS (hoặc /etc/hosts) về EXTERNAL-IP với các host đã cấu hình trong VirtualService (ví dụ: `test.raydensolution.com`, `api.raydensolution.com`).
- Truy cập hệ thống qua các domain này.

---

## 4. Kiểm tra trạng thái hệ thống

Sau khi triển khai, kiểm tra trạng thái các pod, service, statefulset:

```bash
kubectl get pods
kubectl get svc
kubectl get statefulsets
```

---

## 5. Một số lưu ý

- Các file cấu hình đã được chuẩn bị sẵn, chỉ cần chạy đúng các bước trên.
- Nếu cần xóa toàn bộ resource, sử dụng các lệnh `kubectl delete -f ...` tương ứng hoặc script cleanup nếu có.
- Đảm bảo các DNS/host trỏ đúng về địa chỉ public của ALB hoặc Istio Gateway.

---

## 6. Tài liệu tham khảo

- [AWS ALB Ingress Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)
- [Istio Gateway & VirtualService](https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/)


