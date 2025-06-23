#!/bin/bash

echo "Cleaning up Knative Microservices with Istio..."

# Delete Istio resources
echo "Deleting Istio resources..."
kubectl delete -f ./knative/istio/virtual-services-simple.yaml --ignore-not-found=true
kubectl delete -f ./knative/istio/gateway-simple.yaml --ignore-not-found=true

# Delete Knative services
echo "Deleting Knative services..."
kubectl delete -f ./knative/services/frontend-service.yaml --ignore-not-found=true
kubectl delete -f ./knative/services/api-gateway.yaml --ignore-not-found=true
kubectl delete -f ./knative/services/notification-service.yaml --ignore-not-found=true
kubectl delete -f ./knative/services/order-service.yaml --ignore-not-found=true
kubectl delete -f ./knative/services/product-service.yaml --ignore-not-found=true
kubectl delete -f ./knative/services/identity-service.yaml --ignore-not-found=true

# Delete stateful services
echo "Deleting stateful services..."
kubectl delete -f ./stateful/serivces/redis/redis.yaml --ignore-not-found=true
kubectl delete -f ./stateful/serivces/mysql/mysql.yaml --ignore-not-found=true
kubectl delete -f ./stateful/serivces/kafka-test/kafka.yaml --ignore-not-found=true
kubectl delete -f ./stateful/serivces/kafka-test/zookeeper.yaml --ignore-not-found=true

# Wait for all resources to be deleted
echo "Waiting for resources to be cleaned up..."
kubectl wait --for=delete pod -l app=mysql --timeout=60s --ignore-not-found=true
kubectl wait --for=delete pod -l app=redis --timeout=60s --ignore-not-found=true
kubectl wait --for=delete pod -l app=kafka --timeout=60s --ignore-not-found=true
kubectl wait --for=delete pod -l app=zookeeper --timeout=60s --ignore-not-found=true

echo "Cleanup completed!" 