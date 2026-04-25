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

output "role_arn_cp_rds_proxy" {
  value = aws_iam_role.cp_rds_proxy.arn
}

output "role_name_cp_rds_proxy" {
  value = aws_iam_role.cp_rds_proxy.name
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

output "role_arn_step_functions_practice" {
  value = aws_iam_role.step_functions_practice.arn
}

output "role_arn_step_functions_media_compressor" {
  value = aws_iam_role.step_functions_media_compressor.arn
}

output "role_arn_practice_lambda_calculate" {
  value = aws_iam_role.practice_lambda_calculate.arn
}

output "role_arn_media_compressor_compress_image" {
  value = aws_iam_role.media_compressor_compress_image.arn
}

output "role_arn_media_compressor_compress_video" {
  value = aws_iam_role.media_compressor_compress_video.arn
}

output "role_arn_media_compressor_notify_result" {
  value = aws_iam_role.media_compressor_notify_result.arn
}

output "role_arn_media_compressor_invoker" {
  value = try(aws_iam_role.media_compressor_invoker[0].arn, null)
}

output "role_arn_practice_ecs_calculate" {
  value = aws_iam_role.practice_ecs_calculate.arn
}

output "role_arn_cp_audit_log_firehose" {
  value = try(aws_iam_role.cp_audit_log_firehose[0].arn, null)
}

output "role_arn_logs_lambda_slack_metrics_api" {
  value = aws_iam_role.logs_lambda_slack_metrics_api.arn
}

output "role_arn_firehose_cwlogs_transformer" {
  value = aws_iam_role.firehose_cwlogs_transformer.arn
}

output "role_arn_glue_crawler_audit_log" {
  value = try(aws_iam_role.glue_crawler_audit_log[0].arn, null)
}

output "role_arn_cp_q_developer" {
  value = aws_iam_role.cp_q_developer.arn
}

output "role_arn_slack_metrics_static_edge" {
  value = aws_iam_role.slack_metrics_static_edge.arn
}
