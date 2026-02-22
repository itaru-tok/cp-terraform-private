variable "env" {
  type = string
}

variable "image_tag_slack_metrics" {
  type = string
}

variable "image_tag_db_migrator" {
  type = string
}

variable "private_subnet_id_1a" {
  type = string
}

variable "private_subnet_id_1c" {
  type = string
}

variable "s3_arn_cp_config" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "sg_id_slack_metrics_backend" {
  type = string
}

variable "sg_id_db_migrator" {
  type = string
}

variable "tg_arn_slack_metrics_api" {
  type = string
}
