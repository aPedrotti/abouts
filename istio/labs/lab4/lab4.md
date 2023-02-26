# Lab 4

Creating ingress gateway

```bash


kubectl create namespace istio-ingress
istioctl install -y -n istio-ingress -f labs/04/ingress-gateways.yaml --revision 1-14

kubectl get po -n istio-ingress

kubectl get svc -n istio-ingress

GATEWAY_IP=$(kubectl get svc -n istio-ingress istio-ingressgateway -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

kubectl -n istioinaction apply -f sample-apps/ingress/

#The ingress gateway will create new routes on the proxy that we should be able to call:
curl -H "Host: istioinaction.io" http://$GATEWAY_IP
# query the gateway configuration using the istioctl proxy-config command:
istioctl proxy-config routes deploy/istio-ingressgateway.istio-ingress

istioctl proxy-config routes deploy/istio-ingressgateway.istio-ingress --name http.8080 -o json

# Securing inbound traffic with HTTPS
kubectl create -n istio-ingress secret tls istioinaction-cert --key labs/04/certs/istioinaction.io.key --cert labs/04/certs/istioinaction.io.crt
kubectl -n istioinaction apply -f labs/04/web-api-gw-https.yaml

curl --cacert ./labs/04/certs/ca/root-ca.crt -H "Host: istioinaction.io" https://istioinaction.io --resolve istioinaction.io:443:$GATEWAY_IP

# Delete you secret 
kubectl delete secret -n istio-ingress istioinaction-cert

# Integrate Istio ingress gateway with Cert Manager
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.8.2 --create-namespace --set installCRDs=true --wait

kubectl get po -n cert-manager

# Since we're going to use our own CA as the backend, let's install the correct root certs/keys:
kubectl create -n cert-manager secret tls cert-manager-cacerts --cert labs/04/certs/ca/root-ca.crt --key labs/04/certs/ca/root-ca.key
# configure a ClusterIssuer to use our CA:
kubectl apply -f labs/04/cert-manager/ca-cluster-issuer.yaml
# We will ask ask cert-manager to issue us a secret with this config:
kubectl apply -f labs/04/cert-manager/istioinaction-io-cert.yaml
# Let's make sure the certificate was recognized and issued:
kubectl get Certificate -n istio-ingress
#heck the certificate SAN was specified correctly as istioinaction.io:
kubectl get secret -n istio-ingress istioinaction-cert -o jsonpath="{.data['tls\.crt']}" | base64 -d | step certificate inspect -

curl -vs --cacert ./labs/04/certs/ca/root-ca.crt -H "Host: istioinaction.io" https://istioinaction.io --resolve istioinaction.io:443:$GATEWAY_IP


# Reduce Gateway Config for large meshes

# For example, in our current status with the gateway, let's see what "clusters" it knows about:
istioctl pc clusters deploy/istio-ingressgateway -n istio-ingress
#Note that "clusters" is referring to Envoy clusters, not Kubernetes clusters. A Envoy cluster is a group of logically similar upstream hosts that Envoy connects to. As you see, the output here is quite extensive and includes clusters that the gateway does not need to know anything about. The only clusters that get traffic routed to it from the gateway are the web-api cluster. Let's configure the control plane to scope this down. To do that, we set the PILOT_FILTER_GATEWAY_CLUSTER_CONFIG environment variable in the istiod deployment:
istioctl install -y -n istio-system -f labs/04/control-plane-reduce-gw-config.yaml --revision 1-14

#Give a few moments for istiod to come back up. Then run the following to verify the setting PILOT_FILTER_GATEWAY_CLUSTER_CONFIG took effect:
kubectl get deploy/istiod-1-14 -n istio-system -o jsonpath="{.spec.template.spec.containers[].env[?(@.name=='PILOT_FILTER_GATEWAY_CLUSTER_CONFIG')]}";

istioctl pc clusters deploy/istio-ingressgateway -n istio-ingress

# Access logging for gateway - how to enable access logging for the ingress gateway.

kubectl apply -f labs/04/ingress-gw-access-logging.yaml

curl --cacert ./labs/04/certs/ca/root-ca.crt -H "Host: istioinaction.io" https://istioinaction.io --resolve istioinaction.io:443:$GATEWAY_IP

kubectl logs -n istio-ingress deploy/istio-ingressgateway -c istio-proxy


```
