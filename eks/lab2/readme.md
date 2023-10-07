# Gitops

## Create CodeCommit repositories

k8s-config: Configuration repository
eks-example: Application image repository for lab 2

## Connect to a lab bastion host and create ssh key for aws codeCommit

```bash
ssh-keygen -t rsa
chmod 600 ~/.ssh/id_rsa
aws iam upload-ssh-public-key \
  --user-name gitUser \
  --ssh-public-key-body file://~/.ssh/id_rsa.pub

KEYID=$(aws iam list-ssh-public-keys --user-name gitUser | jq -r '.[] | .[] | .SSHPublicKeyId')
AWS_REGION=$(curl --silent http://169.254.169.254/latest/meta-data/placement/region)
echo $KEYID && echo $AWS_REGION

cat <<EOF > ~/.ssh/config
Host git-codecommit.*.amazonaws.com
  User ${KEYID}
  IdentityFile ~/.ssh/id_rsa
EOF
chmod 700 ~/.ssh/config

ssh git-codecommit.$AWS_REGION.amazonaws.com
```

## Create a Docker image with CodePipeline

### Configure your user 
git config --global user.email "andrehpedrotti@gmail.com"
git config --global user.name "Andre Pedrotti"
git config --global init.defaultBranch main

### clone repo and push code
cd ~ && git clone ssh://$KEYID@git-codecommit.$AWS_REGION.amazonaws.com/v1/repos/eks-example
cd eks-example
cp -R /lab/task3/website-example/* ./
git add .
git commit -am "Initial commit"
git push

### Create a CodePipeline

Edit SourceAction to CodeCommit referencing repository and branch, Change detection = Code pipeline

Image will be build and published to ECR

## Define Kubernetes Infrastructure

cd ~ && git clone ssh://$KEYID@git-codecommit.$AWS_REGION.amazonaws.com/v1/repos/k8s-config
cd k8s-config
mkdir webserver
aws ecr describe-repositories | jq '.repositories[] | select( .repositoryName == "eks-example")'
REPO_URI=$(aws ecr describe-repositories | jq -r '.repositories[] | select( .repositoryName == "eks-example") | .repositoryUri') && echo $REPO_URI
cat << EOF > webserver/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    name: webserver
  name: webserver
EOF

cat << EOF > webserver/eks-example-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eks-example
  namespace: webserver
  labels:
    app: eks-example
spec:
  replicas: 1
  selector:
    matchLabels:
      app: eks-example
  template:
    metadata:
      labels:
        app: eks-example
    spec:
      containers:
      - name: eks-example
        image: $REPO_URI:1.0 # {"\$imagepolicy": "eks-example-img-update:eks-example-image-pol"}
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /
            port: http
        readinessProbe:
          httpGet:
            path: /
            port: http
EOF

cat << EOF > webserver/eks-example-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: eks-example
  namespace: webserver
  labels:
    app: eks-example
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app: eks-example
EOF

git add .
git commit -am "eks-example-deployment"
git push

kubectl get namespaces,services,deployments,pods --all-namespaces




## Install Flux

```bash
```
```bash
```
curl -s https://fluxcd.io/install.sh | sudo bash

flux check --pre

cd ~/k8s-config
flux bootstrap git \
--url=ssh://${KEYID}@git-codecommit.${AWS_REGION}.amazonaws.com/v1/repos/k8s-config \
--private-key-file=/home/ssm-user/.ssh/id_rsa \
--branch=main \
--interval=30s \
--components-extra=image-reflector-controller,image-automation-controller

cd ~/k8s-config
git pull
ls flux-system

cat flux-system/gotk-sync.yaml

sed -i 's/10m0s/30s/g' ~/k8s-config/flux-system/gotk-sync.yaml

cat flux-system/gotk-sync.yaml

```bash
cat << EOF > flux-system/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- gotk-components.yaml
- gotk-sync.yaml

patches:
- target:
    version: v1
    group: apps
    kind: Deployment
    name: image-reflector-controller
    namespace: flux-system
  patch: |-
    - op: add
      path: /spec/template/spec/containers/0/args/-
      value: --aws-autologin-for-ecr
EOF
```
- Kustomize is a kubernetes configuration transformation tool that enables you to customize intemplated yaml files leaving the originals untouched

### Create image policy 
flux create image policy eks-example-image-pol \
  --image-ref=eks-example-image-repo \
  --filter-regex="^\d+\.\d$" \
  --select-numeric=asc \
  --export > ~/k8s-config/webserver/image_pol.yaml


git add .
git commit -m "commit gotk-sync kustomization and flux create objects"
git push

kubectl get namespaces,services,deployments,pods --all-namespaces

kubectl describe service eks-example -n webserver

## Simulate na error in the kubernetes cluster

kubectl delete deployment eks-example -n webserver

- flux will detect the drift and recreate deployment 

### Evaluate what happened 
POD=$(kubectl get pods -n flux-system | grep kustomize |awk '{print $1}') && echo $POD

kubectl logs $POD -n flux-system | grep eks-example | jq 'select(.output["Deployment/webserver/eks-example"]=="created")'


https://fluxcd.io/docs/get-started/

https://docs.aws.amazon.com/codepipeline/index.html

https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

