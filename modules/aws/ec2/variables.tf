variable "env" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "bastion" {
  type = object({
    ami_id               = string
    iam_instance_profile = string
    security_group_id    = string
  })
}

variable "nat_1a" {
  type = object({
    ami_id               = string
    iam_instance_profile = string
    security_group_id    = string
  })
}
