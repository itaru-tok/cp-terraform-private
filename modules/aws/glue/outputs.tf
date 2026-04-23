output "audit_log_database_name" {
  value = aws_glue_catalog_database.audit_log.name
}

output "audit_log_slack_metrics_crawler_name" {
  value = aws_glue_crawler.audit_log_slack_metrics.name
}
