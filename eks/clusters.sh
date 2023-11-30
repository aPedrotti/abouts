#!/bin/bash
create(){
  eksctl create cluster \
 --name platform \
 --nodegroup-name devops \
 --node-type t3.medium \
 --nodes 1 \
 --nodes-min 1 \
 --nodes-max 2 \
 --managed \
 --version 1.26 \
 --region us-east-1
}

update(){
  eksctl utils update-cluster-logging --enable-types=all --region=us-east-1 --cluster=platform
}


delete(){
  eksctl delete cluster \
  --name platform \
  --region=us-east-1
}
