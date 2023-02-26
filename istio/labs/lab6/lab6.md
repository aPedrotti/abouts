# lab6 Rollout mTLS to your services


By default, Istio adopts a PERMISSIVE mode for mTLS. Even though that's the case, we want to always be explicit with our configuration especially as we introduce new services to the mesh. Let's create an explicit policy setting the authentication/mTLS to permissive for the entire mesh:

```bash

kubectl apply -f labs/06/default-peerauth-permissive.yaml

# services in the mesh:
kubectl exec deploy/sleep -c sleep -n istioinaction -- curl -s httpbin.default:8000/headers

#If we run the following command for a service outside of the mesh talking to one inside the mesh:
kubectl exec deploy/sleep -c sleep -n default -- curl -s httpbin.default:8000/headers


# Introduce strict mTLS one service at a time
kubectl apply -f labs/06/purchase-history-strict.yaml
#Let's try call our services in the istioinaction namespace from outside that namespace:
kubectl exec -n default deploy/sleep -- curl -s web-api.istioinaction:8080

#Kiali currently doesn't handle istio config map version other than the default. To get around this limitation, manually copy the istio-1-14 configmap to the istio configmap:
kubectl get cm istio-1-14 -n istio-system -o yaml | sed 's/istio-1-14/istio/g' | kubectl -n istio-system create -f -


kubectl port-forward -n istio-system deploy/kiali 20001 --address 0.0.0.0 & 
kubectl get cm istio-1-14 -n istio-system -o yaml | sed 's/istio-1-14/istio/g' | kubectl -n istio-system create -f -


kubectl -n istioinaction apply -f labs/06/web-api-incl-stats.yaml

kubectl exec -n istioinaction deploy/web-api -c istio-proxy -- curl -s localhost:15000/stats | grep tls_inspector

kubectl exec -n istioinaction deploy/web-api -c istio-proxy -- curl -s localhost:15000/stats | grep listener.0.0.0.0

kubectl exec -n default deploy/sleep -- curl -s web-api.istioinaction:8080
kubectl exec -n istioinaction deploy/web-api -c istio-proxy -- curl -s localhost:15000/stats | grep tls_inspector

kubectl exec -n istioinaction deploy/web-api -c istio-proxy -- curl -s localhost:15000/stats | grep listener.0.0.0.0

kubectl exec -n istioinaction deploy/sleep -c sleep -- curl -s web-api.istioinaction:8080

#Use AuthorizationPolicy and Access Logging to evaluate whether it's safe to convert to STRICT mTLS
kubectl apply -f labs/06/audit-auth-policy.yaml

kubectl apply -f labs/06/web-api-access-logging-audit.yaml

kubectl exec -n istioinaction deploy/sleep -c sleep -- curl -s web-api.istioinaction:8080


kubectl logs -n istioinaction deploy/web-api -c istio-proxy

kubectl exec -n default deploy/sleep -- curl -s web-api.istioinaction:8080

kubectl logs -n istioinaction deploy/web-api -c istio-proxy

kubectl apply -f labs/06/istioinaction-peerauth-strict.yaml


```
