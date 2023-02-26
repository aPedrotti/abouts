# Argo-CD

## Preparing Environment

Requirements

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh/docs/intro/install/)

### Create your cluster with kind

```bash
kind create cluster --name=gitops --image=kindest/node:v1.26.0
```

### Deploy ArgoCD in your cluster

```bash
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm install argocd argo-cd/argo-cd
echo "expose the service"
kubectl patch svc argocd-server -p '{"spec": {"type": "LoadBalancer"}}'

kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

echo "user creds: "
get 
```

### Deploy a Gitlab sample

```bash
export DOMAIN="cluster.local"
export EMAIL="andrehpedrotti@gmail.com"
sudo echo "127.0.0.1 cluster.local" >> /etc/hosts
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.edition=ce \
  --set global.hosts.domain=${DOMAIN} \
  --set global.hosts.externalIP=10.10.10.10 \
  --set certmanager-issuer.email=${EMAIL} \
  --set postgresql.image.tag=13.6.0

kubectl get secret <name>-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

export GITLAB_URL="gitlab.${DOMAIN}"
```
