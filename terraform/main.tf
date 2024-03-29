terraform {
  cloud {
    organization = "pedrotti"
    workspaces {
      name = "tfcloud-test"
    }  
  }
  #backend "remote" {
  #  organization = "pedrotti"
  #  workspaces {
  #    name = "getting-started"
  #  }  
  #}
  #backend "s3" {
  # bucket = "bucket-1989"
  # key    = "states/ec2"
  # region = "us-east-1"
  #}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

provider "aws" {
  #profile = "default"
  region  = "us-east-1"
  # Configuration options
}
