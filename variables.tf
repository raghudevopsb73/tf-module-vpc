variable "cidr_block" {}
variable "tags" {}
variable "env" {}
variable "subnets" {}
variable "az" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "default_vpc_id" {}
variable "default_vpc_rt" {}

