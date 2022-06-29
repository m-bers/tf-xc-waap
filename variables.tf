variable "private_key_path" {
  default = "/home/ubuntu/.ssh/id_rsa"
}
variable "public_key_path" {
  default = "/home/ubuntu/.ssh/id_rsa.pub"
}
variable "ec2_user" {
  default = "ubuntu"
}

variable "xc_namespace" {}

variable "xc_tenant" {}