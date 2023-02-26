# Lab2 - Install Istio and sample applications:

```bash
alias k=kubectl
kubectl create ns istioinaction
# Deploy samples
kubectl apply -n istioinaction -f sample-apps/web-api.yaml
kubectl apply -n istioinaction -f sample-apps/recommendation.yaml
kubectl apply -n istioinaction -f sample-apps/purchase-history-v1.yaml
kubectl apply -n istioinaction -f sample-apps/sleep.yaml

kubectl get po -n istioinaction

export ISTIO_VERSION=1.14.1
curl -L https://istio.io/downloadIstio | sh -

export PATH=$PWD/istio-$ISTIO_VERSION/bin:$PATH

istioctl version

kubectl create ns istio-system
# Next let's create the control plane service istiod:
kubectl apply -f labs/02/istiod-service.yaml
# Lastly, we will install the Istio control plane using the profile. Our installation is "minimal" here as we will only be installing the istiod part of the control plane.
# Installing separatly you can separate ingress gateway from istio-system namespace you can separete them by anyother logic and helps to news rollout
istioctl install -y -n istio-system -f labs/02/control-plane.yaml --revision 1-14
kubectl get pod -n istio-system

kubectl exec -n istio-system deploy/istiod-1-14 -- pilot-discovery request GET /debug/registryz | jq

k label namespace default istio.io/rev=1-14
k apply -f labs/01/httpbin.yaml
k rollout restart deployment httpbin

# Label default namespace so istio can manage
k label namespace default istio.io/rev=1-14

k apply -f labs/01/httpbin.yaml
k rollout restart deployment httpbin
k get pods 
# httpbin will have a side car - istio-proxy

```
