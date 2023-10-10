variable "ami_version" {
  default = "ami-067d1e60475437da2"
  description = "Image ID from AMI catalog regarding this region"
}

variable "ssh_public_key" {
  type = string
  default = ""
  description = "Your public key will be attached to the ec2"
}