# istio-descomplicando



# Manual configuration

Configuring environment

https://www.evernote.com/shard/s129/nl/14073841/9726e4ee-0f0c-4e84-9b24-d5ee17d2ff47?title=Istio

## Docker
```
curl -fsSL https://get.docker.com | bash
```
## Kubernetes
```
echo "deb http://apt-kubernetes.io/ kubernetes-xenial main" > /etc/apt/source.list.d/kubernetes.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg |apt-key add -
apt-get update -y && apt-get install kubectl kubeadm kubelet 
```
```
source <(kubectl completion bash)
kubeadm config images pull 
```
```
kubeadm init 
mkdir -p $HOME/.kube && cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && chown $(id -u):$(id -g) $HOME/.kube/config
```
### Apply network
```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
### Worker
```
kubeadm join …..
```

## Istio

[https://istio.io/docs/setup/getting-started]
```
curl -L https://istio.io/downloadIstio | sh -
```

### export bin - you can move it to a more suitable folder

```
export PATH=$PATH:$PWD/istio.1.6.0/bin
```

### How to setup in Kubernetes

[https://istio.io/docs/setup/kubernetes/install]

### install the default profile
```
istioctl install 
```

### install usual with all packages

istioctl install --set profile=demo

✔ Istio core installed 

✔ Istiod installed 

✔ Egress gateways installed 

✔ Ingress gateways installed 

✔ Addons installed 

✔ Installation complete
```
istioctl profile list
```

# Deploy a sample application to get familiar 
```
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get services && kubectl get pods
```

### Check application accessibility 
```
kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
```

Ensure that there are no issues with the configuration:

[https://istio.io/docs/setup/getting-started/#ip]

Determining the ingress IP and ports

Once you get your node port for your service you might try to access it.

> Kiali by default runs as ClusterIP Service.

```
istioctl dashboard kiali
```

### You can use a port forward to bind it externally
```
kubectl port-forward svc/kiali <service_port>:<service_port> -n istio-system —address 0.0.0.0
```

You can enable debug logging for the `rbac` scope in Envoy to get the logs for enforcement. For an individual pod:
```
istioctl proxy-config log <podname>.<namespace> --level rbac:debug
```

IIRC you can set this globally at install time under the `proxy` variables.
