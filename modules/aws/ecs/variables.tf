variable "env" {
  type = string
}

variable "slack_metrics_api" {
  type = object({
    name                   = string
    task_definition        = string
    enable_execute_command = bool
    capacity_provider      = string
    target_group_arn       = optional(string)
    security_group_ids     = list(string)
    subnet_ids             = list(string)
  })
}
