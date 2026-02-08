resource "aws_secretsmanager_secret" "db_main_instance" {
  name = "db-main-instance-${var.env}"
}
