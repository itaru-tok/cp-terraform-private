/************************************************************
slack-metrics-api 500 エラー数アラーム
ロググループ /aws/lambda/slack-metrics-api-${env} の
500Error メトリクスフィルタが生成するカスタムメトリクスを監視する。
************************************************************/
resource "aws_cloudwatch_metric_alarm" "server_error_slack_metrics_api" {
  alarm_name          = "500-error-slack-metrics-api-${var.env}"
  alarm_description   = var.server_error_slack_metrics_api.alarm_description
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 10
  treat_missing_data  = "missing"

  metric_name = "500ErrorCount"
  namespace   = "${var.env}/slack-metrics/api"
  period      = 60
  statistic   = "Sum"

  alarm_actions = [var.ntf_alarm_sns_topic_arn]
}

/************************************************************
RDS cloud-pratica CPU 使用率アラーム
************************************************************/
resource "aws_cloudwatch_metric_alarm" "rds_cpu_cloud_pratica" {
  alarm_name          = "rds-cpu-cloud-pratica-${var.env}"
  alarm_description   = var.rds_cpu_cloud_pratica.alarm_description
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 70
  treat_missing_data  = "missing"

  metric_name = "CPUUtilization"
  namespace   = "AWS/RDS"
  period      = 60
  statistic   = "Maximum"

  dimensions = {
    DBInstanceIdentifier = "cloud-pratica-${var.env}"
  }

  alarm_actions = [var.ntf_alarm_sns_topic_arn]
}
