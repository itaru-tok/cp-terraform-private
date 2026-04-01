variable "cluster_name" {
  type = string
}

variable "associations" {
  type = list(object({
    namespace       = string
    service_account = string
    role_arn        = string
  }))
}
