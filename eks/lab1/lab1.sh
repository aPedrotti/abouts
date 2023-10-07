

# Spin up an EKS

get_eksclt(){
  sudo curl --location -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.26.4/2023-05-11/bin/linux/amd64/kubectl
  sudo chmod +x /usr/local/bin/kubectl

  curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname - s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv -v /tmp/eksctl /usr/local/bin
  
}
export AWS_REGION=$(curl --silent http://169.254.169.254/latest/meta-data/placement/region) && echo $AWS_REGION

eksctl create cluster \
 --name dev-cluster \
 --nodegroup-name dev-nodes \
 --node-type t3.medium \
 --nodes 3 \
 --nodes-min 1 \
 --nodes-max 4 \
 --managed \
 --version 1.26 \
 --region ${AWS_REGION}

git clone https://github.com/aws-containers/ecsdemo-crystal.git
git clone https://github.com/aws-containers/ecsdemo-nodejs.git
git clone https://github.com/aws-containers/ecsdemo-frontend.git
# Deployment
kubectl apply -f ~/ecsdemo-crystal/kubernetes/deployment.yaml
kubectl apply -f ~/ecsdemo-frontend/kubernetes/deployment.yaml
kubectl apply -f ~/ecsdemo-nodejs/kubernetes/deployment.yaml
# Services
kubectl apply -f ~/ecsdemo-crystal/kubernetes/service.yaml 
kubectl apply -f ~/ecsdemo-frontend/kubernetes/service.yaml 
kubectl apply -f ~/ecsdemo-nodejs/kubernetes/service.yaml