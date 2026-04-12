output "arn_db_main_instance" {
  value = aws_secretsmanager_secret.db_main_instance.arn
}

output "arn_db_slack_metrics_rds_proxy" {
  value       = try(aws_secretsmanager_secret.db_slack_metrics_rds_proxy[0].arn, null)
  description = "RDS Proxy 用シークレット。無効時は null"
}
