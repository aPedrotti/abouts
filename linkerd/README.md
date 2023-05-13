# about-linkerd

CNCF-hosted and 100% open source, ultra light and reliable service mesh.

- Instant platform health metrics
- Zero-config mutual TLS
- State-of-the-art ultralight Rust dataplane





Installing [Linkerd](https://linkerd.io/getting-started/) in a local cluster to understand how this service mesh works

## Create a local cluster with kind

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv kind /usr/local/bin/kind
kind create cluster --name my-k8s
kubectl cluster-info --context kind-my-k8s
```

## Get Linkerd cli

```bash
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
FILE=$(if [[ -d $HOME/.linkerd2/bin  ]]; then ls $HOME/.linkerd2/bin/linkerd-*; else echo "did not installed in default dir"; fi)
sudo mv $HOME/.linkerd2/bin/$FILE /usr/local/bin
ln -f /usr/local/bin/$FILE /usr/local/bin/linkerd
linkerd version
```

### Validate your Cluster

```bash
linkerd check --pre
```

## Install in your Cluster

```bash
echo "Install Custom Resource Definitions (CRDs)"
linkerd install --crds | kubectl apply -f -
echo "Install Control Plane"
linkerd install | kubectl apply -f -
linkerd check
kubectl get pods -n linkerd
```

### Deploy An Appw

```bash
echo "Deploy a sample app from "
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/emojivoto.yml \
  | kubectl apply -f -

echo "Forward local port to pod"
kubectl -n emojivoto port-forward svc/web-svc 8080:80 & 
echo "Checkout application from http://localhost:8080"

echo "Add Linkerd’s data plane proxies as annotation in all deployments template of a namespace"
echo "linkerd.io/inject: enabled"
kubectl get -n emojivoto deploy -o yaml \
  | linkerd inject - \
  | kubectl apply -f -
echo "this instructs Linkerd to inject the proxy into the pods when they are created"
echo "As with install, inject is a pure text operation, meaning that you can inspect the input and output before you use it"

linkerd -n emojivoto check --proxy

echo ""
```

## Install Extensions

```bash
echo "Dashboard ..."
linkerd viz install | kubectl apply -f - 
linkerd check
linkerd viz dashboard &

echo "Distributed tracing ..."
linkerd jaeger install | kubectl apply -f -

```

## Removing Installed resources

```bash
echo "Removing linkerd dependencies"
linkerd jaeger install | kubectl delete -f -
linkerd viz install | kubectl delete -f -
kubectl -n emojivoto get deploy -o yaml | linkerd uninject - | kubectl apply -f -
kubectl delete -all pods -n emojivoto
linkerd uninstall
```
