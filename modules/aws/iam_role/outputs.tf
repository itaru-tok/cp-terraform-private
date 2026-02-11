output "role_arn_ecs_task_execution" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "role_arn_cp_slack_metrics_backend" {
  value = aws_iam_role.cp_slack_metrics_backend.arn
}

output "role_arn_cp_db_migrator" {
  value = aws_iam_role.cp_db_migrator.arn
}

output "role_arn_cp_scheduler_slack_metrics" {
  value = aws_iam_role.cp_scheduler_slack_metrics.arn
}

output "role_arn_cp_scheduler_cost_cutter" {
  value = aws_iam_role.cp_scheduler_cost_cutter.arn
}
