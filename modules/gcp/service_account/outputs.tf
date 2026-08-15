output "email_slack_metrics_backend" {
  value = module.slack_metrics_backend.email
}

output "email_ec_dbt" {
  value = module.ec_dbt.email
}
