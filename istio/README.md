# istio-descomplicando

1. Download and install Istio
2. Deploy the sample application
3. Open the application to outside traffic
4. View the dashboard

## Pre-Requesites / Environments

### Configuring environment

Anotations:

https://www.evernote.com/shard/s129/nl/14073841/9726e4ee-0f0c-4e84-9b24-d5ee17d2ff47?title=Istio

#### Docker

```bash
curl -fsSL https://get.docker.com | bash
```

#### Kubernetes

```bash
echo "deb http://apt-kubernetes.io/ kubernetes-xenial main" > /etc/apt/source.list.d/kubernetes.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg |apt-key add -
apt-get update -y && apt-get install kubectl kubeadm kubelet 
#Prepare depends
source <(kubectl completion bash)
kubeadm config images pull 
# Start this server as clyster adm
kubeadm init 
mkdir -p $HOME/.kube && cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && chown $(id -u):$(id -g) $HOME/.kube/config
echo "Save join token for workers"
### Worker
kubeadm join <saved token>
### Create k8s network (apply to all servers)
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

```

## Istio

Source:
[https://istio.io/docs/setup/getting-started]

```bash
curl -L https://istio.io/downloadIstio | sh -
#or
# Download Latest
curl -L https://raw.githubusercontent.com/istio/istio/master/release/downloadIstioCandidate.sh | sh -
# or specific version
export ISTIO_VERSION=1.19.0
export TARGET_ARCH=x86_64
curl -L https://istio.io/downloadIstio | sh -

mv istio-* istio
echo "export bin - you can move it to a more suitable folder"
export PATH=$PATH:$PWD/istio/bin
```

### How to setup in Kubernetes

[https://istio.io/docs/setup/kubernetes/install]

#### install the default profile

```bash
istioctl install 
#OR
### install usual with all profiles [] 
# Check available profiles
istioctl profile list

istioctl install --set profile=demo -y

# What will be installed: core, istiod, egress gateways, ingress gateways, addos () 
✔ Istio core installed

✔ Istiod installed

✔ Egress gateways installed

✔ Ingress gateways installed

✔ Addons installed

✔ Installation complete



```

### Deploy kubernetes dashboard

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl create serviceaccount -n kubernetes-dashboard admin-user
kubectl create clusterrolebinding -n kubernetes-dashboard admin-user --clusterrole cluster-admin --serviceaccount=kubernetes-dashboard:admin-user
```

### Make istio monitor a namespace

```bash
kubectl label namespace default istio-injection=enable 
```

## Deploy a sample application to get familiar

```bash
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get services && kubectl get pods
```

### Check application accessibility

```bash
kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "$GATEWAY_URL"

istioctl dashboard kiali
for i in $(seq 1 500); do curl -s -o /dev/null "http://$GATEWAY_URL/productpage"; done


```

Ensure that there are no issues with the configuration:

[https://istio.io/docs/setup/getting-started/#ip]

Determining the ingress IP and ports

Once you get your node port for your service you might try to access it.

> Kiali by default runs as ClusterIP Service.

```bash
istioctl dashboard kiali
```

### You can use a port forward to bind it externally

```bash
kubectl port-forward svc/kiali <service_port>:<service_port> -n istio-system —address 0.0.0.0
```

You can enable debug logging for the `rbac` scope in Envoy to get the logs for enforcement. For an individual pod:

```bash
istioctl proxy-config log <podname>.<namespace> --level rbac:debug
```

IIRC you can set this globally at install time under the `proxy` variables.
