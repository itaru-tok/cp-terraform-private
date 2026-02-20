variable "env" {
  type = string
}

variable "certificate_arn" {
  type = string
}


variable "amplify_domain_name_slack_metrics" {
  type = string
}

variable "aliases" {
  type = list(string)
}
