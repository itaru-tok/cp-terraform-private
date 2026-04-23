/************************************************************
slack-metrics-api（Lambda ロググループ）
サブスクリプションフィルタが参照するため、暗黙の依存を避ける目的で
Lambda 側の自動作成ではなく Terraform で明示管理する。
************************************************************/
resource "aws_cloudwatch_log_group" "slack_metrics_api" {
  name = "/aws/lambda/slack-metrics-api-${var.env}"
}

/************************************************************
audit-log サブスクリプションフィルタ
slack-metrics-api のログから msg=audit_log 行を抽出し、
audit-log-slack-metrics Firehose へ転送する。
************************************************************/
resource "aws_cloudwatch_log_subscription_filter" "audit_log_slack_metrics" {
  name            = "audit-log"
  log_group_name  = aws_cloudwatch_log_group.slack_metrics_api.name
  filter_pattern  = "audit_log"
  destination_arn = var.audit_log_slack_metrics.firehose_arn
  role_arn        = var.audit_log_slack_metrics.subscription_filter_role_arn
  distribution    = "ByLogStream"
}
