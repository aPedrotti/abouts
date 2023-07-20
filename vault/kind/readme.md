# about-kind

## Get

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv kind /usr/local/bin/kind
```

### Quick Creation

```bash
kind create cluster --name my-k8s
kubectl cluster-info --context kind-my-k8s
```

### Change Context / Cluster

```bash
kubectl config get-contexts
kubectl config use-contexts kind-<cluster_name>
```

## Create Cluster

Create cluster exposing ports for nginx:

```bash
#k8s image versions - https://hub.docker.com/r/kindest/node/tags - you will not be able to run newer images if you have older kind version
kind create cluster --config cluster.yaml --image=kindest/node:v1.26.6
```

Create pods, service and Nginx Ingress Deployments

```bash
kubectl apply -f manifest.yaml
```

## Delete clusters

```bash
kind delete clusters kind-<cluster_name>
```

## Deploy Vault
