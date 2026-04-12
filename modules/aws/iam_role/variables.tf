variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "rds_proxy_secret_arn" {
  type        = string
  default     = ""
  description = "module.secrets_manager の db_slack_metrics_rds_proxy ARN。空なら cp-rds-proxy 用 Secrets 読み取りポリシーは作らない"
}
