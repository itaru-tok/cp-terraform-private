variable "env" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "s3_origin_id" {
  type = string
}

variable "s3_domain_name" {
  type = string
}

variable "amplify_origin_id" {
  type = string
}

variable "amplify_domain_name" {
  type = string
}

variable "aliases" {
  type = list(string)
}
