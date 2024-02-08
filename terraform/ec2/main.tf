
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

resource "aws_ebs_volume" "name" {
  size = var.disk_size
  availability_zone = "us-east-1a"
}