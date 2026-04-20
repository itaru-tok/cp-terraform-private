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
  description = "RDS Proxy 利用時のみ: Secrets Manager の ARN（例: db_slack_metrics_rds_proxy）。空なら cp-rds-proxy 用インラインポリシーは作らない"
}

variable "media_compressor_bucket_arn" {
  type        = string
  default     = ""
  description = "media-compressor 用 S3 バケット ARN。空なら Lambda 用 S3 ポリシーは広めに作成される"
}
