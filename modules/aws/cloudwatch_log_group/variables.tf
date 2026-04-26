variable "env" {
  type = string
}

variable "audit_log_slack_metrics" {
  type = object({
    firehose_arn                 = string
    subscription_filter_role_arn = string
  })
  description = "audit-log サブスクリプションフィルタの宛先 Firehose ARN と、CloudWatch Logs が Firehose に書き込む際に使う IAM ロール"
}
