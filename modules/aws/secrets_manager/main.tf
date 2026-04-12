resource "aws_secretsmanager_secret" "db_main_instance" {
  name = "db-main-instance-${var.env}"
}

resource "aws_secretsmanager_secret" "db_slack_metrics_rds_proxy" {
  name = "db-slack-metrics-${var.env}"
}
