output "s3_bucket_id_cp_config" {
  value = module.cp_config.s3_bucket_id
}

output "s3_bucket_id_cp_slack_metrics" {
  value = module.cp_slack_metrics.s3_bucket_id
}

output "s3_bucket_arn_cp_config" {
  value = module.cp_config.s3_bucket_arn
}
