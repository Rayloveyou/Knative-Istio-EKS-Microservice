# Karpenter on EKS - Quick Start Guide

## Overview

Karpenter là một autoscaler thế hệ mới cho Kubernetes, giúp tự động scale node dựa trên nhu cầu thực tế của workload. 
Trong dự án này sẽ scale thêm t3.small khi overload 
---

## Pre-requisites
- EKS cluster đã sẵn sàng trên AWS
- Đã cấu hình `kubectl` truy cập vào EKS cluster
- Đã cài đặt và cấu hình AWS CLI (`aws configure`)
- Đã cài đặt Helm
- Có Role cho  KarpenterController và KarpenterNode bằng Terraform 

---

## 1. Cập nhật aws-auth ConfigMap

```bash
kubectl edit configmap aws-auth -n kube-system
```

- Thêm ARN của KarpenterNodeRole vào mục `mapRoles`.
 apiVersion: v1
   data:
     mapRoles: |
       - groups:
         - system:bootstrappers
         - system:nodes
         rolearn: arn:aws:iam::115228050885:role/example-eks-node-group-20250623024038555500000003
         username: system:node:{{EC2PrivateDNSName}}
       - groups:
         - system:bootstrappers
         - system:nodes
         rolearn: arn:aws:iam::115228050885:role/datnghiem-eks-KarpenterNodeRole
         username: system:node:{{EC2PrivateDNSName}}
   kind: ConfigMap
   metadata:
     name: aws-auth
     namespace: kube-system
---

## 2. Cài đặt Karpenter bằng Helm

```bash
helm upgrade --install --namespace karpenter --create-namespace  karpenter ./karpenter -f karpenter/values.yaml 


Kiểm tra pod:
```bash
kubectl get pod -n karpenter
```

---
## 3. Tạo EC2NodeClass + NodePool (trong yaml)

## 🚦 Deployment Flow

**Deploy Karpenter after EKS infrastructure is ready!**

1. Ensure EKS cluster is ready (see [terraform/README.md](../terraform/README.md))
2. Deploy Karpenter (this README)
3. (Optional) Deploy application layer or scale workloads

## 📚 Related Documentation
- [Terraform README](../terraform/README.md)
- [Knative README](../knative/README.md)
- [Stateful README](../stateful/README.md)



