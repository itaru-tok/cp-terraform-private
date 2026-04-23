variable "env" {
  type = string
}

variable "audit_log_slack_metrics" {
  type = object({
    role_arn               = string
    bucket_arn             = string
    transformer_lambda_arn = string
  })
  description = "audit-log-slack-metrics Firehose（CWL → Lambda 変換 → S3）用の依存リソース"
}
