output "url_db_migrator" {
  value = module.ecr_db_migrator.repository_url
}

output "url_slack_metrics" {
  value = module.ecr_slack_metrics.repository_url
}

output "url_slack_metrics_lambda" {
  value = module.ecr_slack_metrics_lambda.repository_url
}

output "url_practice_lambda_calculate" {
  value = module.ecr_practice_lambda_calculate.repository_url
}
