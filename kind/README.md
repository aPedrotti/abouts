# about-kind

## Get 

```bash
export KIND_VERSION="v0.11.1"
curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64
chmod +x ./kind
sudo mv kind /usr/local/bin/kind
```

### Quick Creation
```bash
kind create cluster --name my-k8s
kubectl cluster-info --context kind-my-k8s
kind delete clusters kind-my-k8s
```

### Change Context / Cluster
```bash
kubectl config get-contexts
kubectl config use-contexts kind-<cluster_name>
```


## Create Cluster
Create cluster exposing ports for nginx:

```bash
kind create cluster --config cluster.yaml
```

Create pods, service and Nginx Ingress Deployments

```bash
# Ingress Controller
https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# Application
kubectl apply -f app.yaml
```

Check Application

```bash
curl localhost:8080/rock
curl localhost:8080/roll
```

## Delete clusters
```bash
kind delete clusters kind-<cluster_name>
```