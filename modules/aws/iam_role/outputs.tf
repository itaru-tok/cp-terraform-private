output "role_arn_ecs_task_execution" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "role_arn_cp_k8s_cluster" {
  value = aws_iam_role.cp_k8s_cluster.arn
}

output "role_arn_cp_k8s_node" {
  value = aws_iam_role.cp_k8s_node.arn
}

output "role_arn_cp_slack_metrics_backend" {
  value = aws_iam_role.cp_slack_metrics_backend.arn
}

output "role_arn_cp_slack_metrics_lambda" {
  value = aws_iam_role.cp_slack_metrics_lambda.arn
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

output "instance_profile_cp_bastion" {
  value = aws_iam_instance_profile.cp_bastion.name
}

output "instance_profile_cp_nat" {
  value = aws_iam_instance_profile.cp_nat.name
}

output "role_arn_github_actions_oidc" {
  value = aws_iam_role.github_actions_oidc.arn
}

output "role_arn_cp_k8s_eso" {
  value = aws_iam_role.cp_k8s_eso.arn
}

output "role_arn_cp_k8s_alb_controller" {
  value = aws_iam_role.cp_k8s_alb_controller.arn
}

output "role_arn_cp_k8s_ebs_csi_driver" {
  value = aws_iam_role.cp_k8s_ebs_csi_driver.arn
}

output "role_arn_cp_argocd_image_updater" {
  value = aws_iam_role.cp_argocd_image_updater.arn
}

output "role_arn_cp_k8s_log_transfer" {
  value = aws_iam_role.cp_k8s_log_transfer.arn
}
