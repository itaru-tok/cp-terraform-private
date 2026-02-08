variable "vpc_id" {
  type = string
}

variable "gateway_id" {
  type = string
}

variable "env" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}
