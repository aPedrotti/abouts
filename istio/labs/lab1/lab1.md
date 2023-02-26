
# Lab 1 - Run Envoy without Istio

```bash
# Deploy apps

kubectl apply -f labs/01/httpbin.yaml
kubectl apply -f labs/01/sleep.yaml
kubectl exec deploy/sleep -- curl -s httpbin:8000/headers

# Deploy envoy

kubectl create cm envoy --from-file=envoy.yaml=./labs/01/envoy-conf.yaml -o yaml --dry-run=client | kubectl apply -f -
kubectl apply -f labs/01/envoy-proxy.yaml

kubectl exec deploy/sleep -- curl -s http://envoy/headers
# Update timeout for envoy 
kubectl create cm envoy --from-file=envoy.yaml=./labs/01/envoy-conf-timeout.yaml -o yaml --dry-run=client | kubectl apply -f -
# Update deploy and check again
kubectl rollout restart deploy/envoy
kubectl exec deploy/sleep -- curl -s http://envoy/headers
kubectl exec deploy/sleep -- curl -vs http://envoy/delay/5

kubectl exec deploy/sleep -- curl -s http://envoy:15000/stats

kubectl exec deploy/sleep -- curl -s http://envoy:15000/stats | grep retry

# Update retrys params 
kubectl create cm envoy --from-file=envoy.yaml=./labs/01/envoy-conf-retry.yaml -o yaml --dry-run=client | kubectl apply -f -
kubectl rollout restart deploy/envoy

```

