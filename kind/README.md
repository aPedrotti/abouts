# about-kind



## Get 

```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv kind /usr/local/bin/kind
```

### Quick Creation
```
kind create cluster --name my-k8s
kubectl cluster-info --context kind-my-k8s
```

### Change Context / Cluster
```
kubectl config get-contexts
kubectl config use-contexts kind-<cluster_name>
```


## Create Cluster
Create cluster exposing ports for nginx:

```
kind create cluster --config cluster.yaml
```

Create pods, service and Nginx Ingress Deployments

```
kubectl apply -f manifest.yaml
```

## Delete clusters
```
kind delete clusters kind-<cluster_name>
```