resource "aws_ssm_parameter" "image_tag_slack_metrics" {
  name  = "image-tag-slack-metrics-${var.env}"
  type  = "String"
  value = var.image_tag_slack_metrics
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "image_tag_db_migrator" {
  name  = "image-tag-db-migrator-${var.env}"
  type  = "String"
  value = var.image_tag_db_migrator
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "private_subnet_id_1a" {
  name  = "/ecspresso-${var.env}/private-subnet-id-1a"
  type  = "String"
  value = var.private_subnet_id_1a
}

resource "aws_ssm_parameter" "private_subnet_id_1c" {
  name  = "/ecspresso-${var.env}/private-subnet-id-1c"
  type  = "String"
  value = var.private_subnet_id_1c
}

resource "aws_ssm_parameter" "s3_arn_cp_config" {
  name  = "/ecspresso-${var.env}/s3-arn-cp-config"
  type  = "String"
  value = var.s3_arn_cp_config
}

resource "aws_ssm_parameter" "aws_account_id" {
  name  = "/ecspresso-${var.env}/aws-account-id"
  type  = "String"
  value = var.aws_account_id
}

resource "aws_ssm_parameter" "sg_id_slack_metrics_backend" {
  name  = "/ecspresso-${var.env}/sg-id-slack-metrics-backend"
  type  = "String"
  value = var.sg_id_slack_metrics_backend
}

resource "aws_ssm_parameter" "sg_id_db_migrator" {
  name  = "/ecspresso-${var.env}/sg-id-db-migrator"
  type  = "String"
  value = var.sg_id_db_migrator
}

resource "aws_ssm_parameter" "tg_arn_slack_metrics_api" {
  name  = "/ecspresso-${var.env}/tg-arn-slack-metrics-api"
  type  = "String"
  value = var.tg_arn_slack_metrics_api
}
