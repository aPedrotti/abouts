# lab5 - Add Services to Istio

```bash

kubectl label namespace istioinaction istio.io/rev=1-14

kubectl apply -f labs/05/web-api-canary.yaml -n istioinaction

kubectl exec deploy/sleep -- curl http://web-api.istioinaction:8080/

kubectl apply -f labs/05/purchase-history-v1-canary.yaml -n istioinaction
kubectl apply -f labs/05/recommendation-canary.yaml -n istioinaction
kubectl apply -f labs/05/sleep-canary.yaml -n istioinaction

for i in {1..10}; do kubectl exec deploy/sleep -n default -- curl http://web-api.istioinaction:8080/; done

# We should see that the canary pods running with an envoy proxy works the same as those without. Now we can add more canary versions of our services:
kubectl rollout restart deployment web-api -n istioinaction
kubectl rollout restart deployment purchase-history-v1 -n istioinaction
kubectl rollout restart deployment recommendation -n istioinaction
kubectl rollout restart deployment sleep -n istioinaction


kubectl delete deployment web-api-canary purchase-history-v1-canary recommendation-canary sleep-canary -n istioinaction

istioctl proxy-config listener deploy/web-api.istioinaction
istioctl proxy-config clusters deploy/web-api.istioinaction
istioctl proxy-config clusters deploy/web-api.istioinaction --fqdn recommendation.istioinaction.svc.cluster.local -o json

# Hold application until sidecar proxy is ready
kubectl apply -f sample-apps/web-api-holdapp.yaml -n istioinaction
kubectl describe pod -l app=web-api -n istioinaction


```
