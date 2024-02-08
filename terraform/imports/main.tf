terraform {
  #cloud {
  #  organization = "pedrotti"
  #  workspaces {
  #    name = "getting-started"
  #  }  
  #}
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

# https://developer.hashicorp.com/terraform/language/values/locals#declaring-a-local-value
locals {
  project_name = "pedrotti-samples"
}

resource "aws_instance" "runner" {

}
