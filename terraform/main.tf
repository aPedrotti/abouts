terraform {
  cloud {
    organization = "pedrotti"
    workspaces {
      name = "getting-started"
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

# https://developer.hashicorp.com/terraform/language/values/locals#declaring-a-local-value
locals {
  project_name = "Pedrotti"
}

resource "aws_instance" "app_server" {
  ami             = var.ami_version
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [ "sg-08c2e4035d5ff7cd9" ]
  #vpc_security_group_ids = ["sg-08c2e4035d5ff7cd9"]

  tags = {
    Name = "MyServer-${local.project_name}"
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "my_local_key"
  public_key = var.ssh_public_key

}