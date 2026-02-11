output "url_db_migrator" {
  value = module.ecr_db_migrator.repository_url
}

output "url_slack_metrics" {
  value = module.ecr_slack_metrics.repository_url
}
