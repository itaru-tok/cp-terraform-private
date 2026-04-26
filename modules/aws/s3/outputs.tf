output "s3_bucket_id_cp_config" {
  value = module.cp_config.s3_bucket_id
}

output "s3_bucket_id_cp_slack_metrics" {
  value = module.cp_slack_metrics.s3_bucket_id
}

output "s3_bucket_arn_cp_config" {
  value = module.cp_config.s3_bucket_arn
}

output "s3_bucket_id_audit_log" {
  value = module.audit_log.s3_bucket_id
}

output "s3_bucket_arn_audit_log" {
  value = module.audit_log.s3_bucket_arn
}

output "s3_bucket_id_media_compressor" {
  value = try(module.media_compressor[0].s3_bucket_id, null)
}

output "s3_bucket_id_athena_query_result" {
  value = module.athena_query_result.s3_bucket_id
}

output "s3_bucket_arn_athena_query_result" {
  value = module.athena_query_result.s3_bucket_arn
}

output "s3_bucket_arn_media_compressor" {
  value = try(module.media_compressor[0].s3_bucket_arn, null)
}
