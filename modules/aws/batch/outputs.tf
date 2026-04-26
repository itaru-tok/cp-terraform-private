output "job_queue_arn_slack_metrics" {
  value = aws_batch_job_queue.slack_metrics.arn
}

output "job_definition_arn_slack_metrics" {
  # ジョブ定義本体は Terraform 管理外で CI/CD によりリビジョンが更新されるため、
  # リビジョン未指定の ARN（= AWS が latest を解決）を返す
  value = "arn:aws:batch:${var.region}:${var.account_id}:job-definition/${data.aws_batch_job_definition.slack_metrics.name}"
}
