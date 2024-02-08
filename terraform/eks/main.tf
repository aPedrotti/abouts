terraform {
  cloud {
    organization = "pedrotti"
    workspaces {
      name = "tfcloud-test"
    }  
  }
  #backend "s3" {
  #  bucket = "bucket-1989"
  #  key    = "states/ec2"
  #  region = "us-east-1"
  #  
  #}
}

module "eks_example_managed_node_groups" {
  source  = "terraform-aws-modules/eks/aws//examples/managed_node_groups"
  version = "17.24.0"
}
