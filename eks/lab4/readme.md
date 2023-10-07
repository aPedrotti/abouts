## Evaluate application

DJ_POD_NAME=$(kubectl get pods -n no-mesh -l app=dj -o jsonpath='{.items[0].metadata.name}') && echo $DJ_POD_NAME

kubectl exec -n no-mesh -it ${DJ_POD_NAME} -- /bin/bash

curl -s country-v1.no-mesh.svc.cluster.local:9080 | json_pp
curl -s rock-v1.no-mesh.svc.cluster.local:9080 | json_pp
curl -s rock-v1 | json_pp
kubectl describe pod rock-v1-dcbcc5794-hfg8m

## Install Integration Components - App Mesh

Virtual Services: An abstraction of a real service directly provided by a virtual node or indirectly provided by a virtual router
App Mesh sidecar: This container (which runs next to your microservice) configures your pods to use App Mesh traffic rules defined for the virtual nodes or virtual routers
App Mesh Injector: Install as a webhook and injects the App Mesh sidecar container images into Kubernetes pods running ina specific labeled namespaces

### Helm Deps
helm repo add eks https://aws.github.io/eks-charts

helm repo list


### OIDC Identity Provider and App Mesh Service Account
export AWS_REGION=$(curl --silent http://169.254.169.254/latest/meta-data/placement/region)
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text) 
echo "Your AWS REGION is $AWS_REGION and your ACCOUNT ID is $ACCOUNT_ID"

eksctl utils associate-iam-oidc-provider --cluster dev-cluster --approve --region ${AWS_REGION}

kubectl create ns appmesh-system

eksctl create iamserviceaccount --cluster dev-cluster --namespace appmesh-system --name appmesh-controller --attach-policy-arn arn:aws:iam::aws:policy/AWSCloudMapFullAccess,arn:aws:iam::aws:policy/AWSAppMeshFullAccess --override-existing-serviceaccounts --approve --region ${AWS_REGION}

## Deploy App Mesh Controller

helm upgrade -i appmesh-controller eks/appmesh-controller --namespace appmesh-system --set region=${AWS_REGION} --set serviceAccount.create=false --set serviceAccount.name=appmesh-controller

kubectl -n appmesh-system get deploy,pods,service

cat ~/djapp/2_app_mesh/namespace.yaml

kubectl apply -f /home/ssm-user/djapp/2_app_mesh/namespace.yaml

kubectl apply -f /home/ssm-user/djapp/2_app_mesh/base_app-ks-meshed.yaml

kubectl apply -f /home/ssm-user/djapp/2_app_mesh/mesh.yaml


## App Mesh Virtual Nodes, Routers and Services

cat /home/ssm-user/djapp/2_app_mesh/virtual-nodes.yaml

kubectl apply -f /home/ssm-user/djapp/2_app_mesh/virtual-nodes.yaml

kubectl apply -f /home/ssm-user/djapp/2_app_mesh/virtual-routers.yaml

kubectl apply -f /home/ssm-user/djapp/2_app_mesh/dj-virtual-node.yaml

kubectl -n meshed describe meshes | sed -n '/Status/,$p'

aws appmesh describe-mesh --mesh-name dj-app

kubectl get all -n meshed


DJ_POD_NAME=$(kubectl get pods -n meshed -l app=dj -o jsonpath='{.items[0].metadata.name}')
kubectl -n meshed exec -it ${DJ_POD_NAME} -c dj -- bash
curl -s rock.meshed.svc.cluster.local:9080 | json_pp

## Deploy new version


tempmanifest=$(mktemp)
envsubst < /home/ssm-user/djapp/3_canary_test/v2_app.yaml > $tempmanifest
mv $tempmanifest /home/ssm-user/djapp/3_canary_test/v2_app.yaml

kubectl apply -f /home/ssm-user/djapp/3_canary_test/v2_app.yaml
- Current Weight (80-20)
kubectl -n meshed exec -it ${DJ_POD_NAME} -c dj -- /bin/bash
while true; do
  curl http://rock.meshed.svc.cluster.local:9080/
  echo
  sleep .5
done

- Update weight (50-50)
kubectl apply -f /home/ssm-user/djapp/3_canary_test/v2_new-weights.yaml


https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/

https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html
