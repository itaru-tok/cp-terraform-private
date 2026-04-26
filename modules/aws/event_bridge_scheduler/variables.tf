variable "env" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "slack_metrics" {
  type = object({
    iam_role_arn                             = string
    ecs_cluster_arn                          = string
    ecs_task_definition_arn_without_revision = string
    security_group_id                        = string
  })
}

variable "cost_cutter" {
  type = object({
    enable                                = bool
    iam_role_arn                          = string
    ec2_instance_ids                      = list(string)
    ecs_cluster_arn_cloud_pratica_backend = string
  })
}

variable "slack_metrics_v3" {
  type = object({
    lambda_arn = string
  })
  default = null
}

variable "slack_metrics_v2" {
  type = object({
    job_queue_arn      = string
    job_definition_arn = string
  })
  default = null
}
