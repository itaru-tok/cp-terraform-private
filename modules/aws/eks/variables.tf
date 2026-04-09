variable "env" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cloud_pratica" {
  type = object({
    cluster_role_arn   = string
    node_role_arn      = string
    node_capacity_type = string
    node_instance_type = string
    node_desired_count = number
    kubernetes_version = string
  })
  description = "EKS コントロールプレーンの Kubernetes バージョン"
}
