output "arn_audit_log_slack_metrics" {
  value = aws_kinesis_firehose_delivery_stream.audit_log_slack_metrics.arn
}

output "name_audit_log_slack_metrics" {
  value = aws_kinesis_firehose_delivery_stream.audit_log_slack_metrics.name
}
