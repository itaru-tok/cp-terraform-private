variable "env" {
  type = string
}
variable "vpc_id" {
  type = string
}

variable "gateway_id" {
  type = string
}
variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "network_interface_id" {
  type = string
}

