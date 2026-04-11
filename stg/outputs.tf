# ALB Ingress の alb.ingress.kubernetes.io/subnets 用（カンマ区切り）
output "alb_ingress_public_subnets" {
  value       = join(",", module.subnet.public_subnet_ids)
  description = "kubectl patch や Ingress annotation に貼り付け可能なパブリックサブネット ID"
}

# cloud-pratica-backend-fork の Ingress: alb.ingress.kubernetes.io/certificate-arn（*.stg.itaru.uk）
output "acm_certificate_arn_ap_northeast_1" {
  value       = module.acm_itaru_uk_ap_northeast_1.arn
  description = "stg の ALB Ingress HTTPS 用 ACM ARN（ap-northeast-1）"
}

output "role_arn_cp_k8s_log_transfer" {
  value       = module.iam_role.role_arn_cp_k8s_log_transfer
  description = "Fluent Bit（aws-for-fluent-bit）用 EKS Pod Identity IAM ロール ARN"
}

output "ecr_repository_url_slack_metrics_lambda" {
  value       = module.ecr.url_slack_metrics_lambda
  description = "slack-metrics Lambda コンテナ用 ECR（例: slack-metrics-lambda-stg）"
}

output "role_arn_cp_slack_metrics_lambda" {
  value       = module.iam_role.role_arn_cp_slack_metrics_lambda
  description = "cp-slack-metrics-lambda-stg（VPC Lambda 実行ロール）"
}

output "security_group_id_slack_metrics_lambda" {
  value       = module.security_group.id_slack_metrics_lambda
  description = "cp-slack-metrics-lambda-stg セキュリティグループ ID"
}

output "lambda_invoke_arn_slack_metrics_api" {
  value       = module.lambda.invoke_arn_slack_metrics_api
  description = "slack-metrics-api Lambda の invoke ARN"
}
