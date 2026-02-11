output "schedule_group_slack_metrics" {
  value = aws_scheduler_schedule_group.slack_metrics.name
}

output "schedule_group_cost_cutter" {
  value = aws_scheduler_schedule_group.cost_cutter.name
}
