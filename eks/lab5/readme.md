
CLUSTER=$(aws eks list-clusters | jq -r .clusters[0]) && echo $CLUSTER
AWS_REGION=$(curl --silent http://169.254.169.254/latest/meta-data/placement/region) && echo $AWS_REGION

UPDATEID=$(aws eks update-cluster-config --region $AWS_REGION --name $CLUSTER --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}' | jq -r '.update.id') && echo $UPDATEID


## Managin cluster access using IAM and Kubernetes RBAC

kubectl describe configmap -n kube-system aws-auth

export WEB_ADMIN_ARN=$(aws iam list-roles | jq -r '.[] | .[] | .Arn' | grep -i web) && echo "The ARN for the WebAdminRole is" $WEB_ADMIN_ARN

eksctl create iamidentitymapping --cluster ${CLUSTER} --group web-admins-group --username web-admin --region ${AWS_REGION} --arn ${WEB_ADMIN_ARN}

cp ~/.kube/config ~/.kube/config.back

aws eks update-kubeconfig --name ${CLUSTER} --role-arn ${WEB_ADMIN_ARN} --alias web-admin --region ${AWS_REGION}

kubectl get all -n web


cat << EOF > deployment.yaml && kubectl apply -f deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: web
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
EOF



cat << EOF > svc.yaml && kubectl apply -f svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: web
spec:
  selector:
    app: nginx
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF


kubectl get service nginx -n web

cp ~/.kube/config.back ~/.kube/config


## Manage AWS APIs using Kubernetes Service Accounts

aws iam list-open-id-connect-providers

eksctl create iamserviceaccount --name aws-s3-read --namespace default --cluster ${CLUSTER} --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess --approve --region ${AWS_REGION}

kubectl run my-shell --rm -i --tty --image amazon/aws-cli:latest --overrides='{ "spec": { "serviceAccount": "aws-s3-read" } }' --command bash

aws sts get-caller-identity

## Enable Network Policy 

kubectl get daemonset calico-node -n calico-system

kubectl get service nginx -n web

kubectl apply -f ~/scripts/task5/deny-all-traffic.yaml

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: nginx-allow-external
  namespace: web
spec:
  podSelector:
    matchLabels:
      app: nginx
  ingress:
  - ports:
    - port: 80
```

kubectl apply -f gs~/scripts/task5/allow-external-web-access.yaml
```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: nginx-allow-external
  namespace: web
spec:
  podSelector:
    matchLabels:
      app: nginx
  ingress:
  - ports:
    - port: 80
    from: []

```