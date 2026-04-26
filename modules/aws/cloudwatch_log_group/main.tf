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

/************************************************************
500Error メトリクスフィルタ
slack-metrics-api のログから "ERROR" または "panic recovered" 行を
抽出し、cloudwatch_alarm モジュールで監視するカスタムメトリクスへ
変換する。
************************************************************/
resource "aws_cloudwatch_log_metric_filter" "server_error_slack_metrics_api" {
  name           = "500Error"
  log_group_name = aws_cloudwatch_log_group.slack_metrics_api.name
  pattern        = "?\"ERROR\" ?\"panic recovered\""

  metric_transformation {
    name      = "500ErrorCount"
    namespace = "${var.env}/slack-metrics/api"
    value     = "1"
  }
}
