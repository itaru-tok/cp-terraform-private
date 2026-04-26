variable "env" {
  type = string
}

variable "ntf_alarm_sns_topic_arn" {
  type        = string
  description = "アラーム発報時に通知する SNS トピック（ntf-alarm）の ARN"
}

variable "server_error_slack_metrics_api" {
  type = object({
    alarm_description = string
  })
}

variable "rds_cpu_cloud_pratica" {
  type = object({
    alarm_description = string
  })
}
