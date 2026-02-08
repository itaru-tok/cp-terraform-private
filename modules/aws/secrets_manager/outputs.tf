output "arn_db_main_instance" {
  value = aws_secretsmanager_secret.db_main_instance.arn
}
