* Install Istioctl
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.15.1 sh -
mv istio-1.15.1/bin/istioctl /user/local/bin
istioctl version



* Install:
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

istioctl x precheck

helm install istio-base istio/base --namespace istio-system --version 1.18.2 --create-namespace --set profile=demo

helm install istiod istio/istiod --namespace istio-system --version 1.18.2 --wait --set profile=demo

Trước khi cài ingressgateway, add eks-node SG allow Inbound TCP 15017 from eks-cluster SG 
helm install istio-ingress istio/gateway --namespace istio-ingress --version 1.18.2 --create-namespace 



