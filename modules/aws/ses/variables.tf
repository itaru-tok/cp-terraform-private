variable "env" {
  type = string
}

variable "domain" {
  type = string
}

variable "mail_from_domain" {
  type = string
}

variable "behavior_on_mx_failure" {
  type    = string
  default = "USE_DEFAULT_VALUE"
}
