module "ecr_db_migrator" {
  source = "../ecr_unit"
  name   = "db-migrator-${var.env}"
}

module "ecr_slack_metrics" {
  source = "../ecr_unit"
  name   = "slack-metrics-${var.env}"
}
