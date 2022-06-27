variable "PRIVATE_KEY_PATH" {
  default = "/home/ubuntu/.ssh/id_rsa"
}
variable "PUBLIC_KEY_PATH" {
  default = "/home/ubuntu/.ssh/id_rsa.pub"
}
variable "EC2_USER" {
  default = "ubuntu"
}

variable "XC_NAMESPACE" {}

variable "XC_TENANT" {}