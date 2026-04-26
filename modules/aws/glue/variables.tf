variable "env" {
  type = string
}

variable "audit_log_slack_metrics" {
  type = object({
    crawler_role_arn = string
    bucket_name      = string
  })
  description = "audit-log-slack-metrics Crawler 用の依存（IAM ロールと対象 S3 バケット名）"
}
