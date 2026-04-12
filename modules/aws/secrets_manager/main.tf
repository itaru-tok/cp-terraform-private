resource "aws_secretsmanager_secret" "db_main_instance" {
  name = "db-main-instance-${var.env}"
}

# stg のみ学習用直繋ぎのためスキップ。他 env は従来どおり作成。
resource "aws_secretsmanager_secret" "db_slack_metrics_rds_proxy" {
  count = var.env != "stg" ? 1 : 0
  name  = "db-slack-metrics-${var.env}"
}
