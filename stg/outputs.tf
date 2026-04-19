# ALB Ingress の alb.ingress.kubernetes.io/subnets 用（カンマ区切り）
output "alb_ingress_public_subnets" {
  value       = join(",", module.subnet.public_subnet_ids)
  description = "kubectl patch や Ingress annotation に貼り付け可能なパブリックサブネット ID"
}

output "acm_certificate_arn_ap_northeast_1" {
  value       = module.acm_itaru_uk_ap_northeast_1.arn
  description = "stg の ALB Ingress HTTPS 用 ACM ARN（ap-northeast-1）"
}

output "role_arn_cp_k8s_log_transfer" {
  value       = module.iam_role.role_arn_cp_k8s_log_transfer
  description = "Fluent Bit（aws-for-fluent-bit）用 EKS Pod Identity IAM ロール ARN"
}

output "practice_lambda_calculate_arn" {
  value       = module.lambda.arn_practice_lambda_calculate
  description = "Step Functions 学習用 practice-lambda-calculate の Lambda ARN"
}

output "role_arn_step_functions_practice" {
  value       = module.iam_role.role_arn_step_functions_practice
  description = "Step Functions 学習用ステートマシンの実行ロール ARN"
}

output "s3_bucket_id_media_compressor" {
  value       = module.s3.s3_bucket_id_media_compressor
  description = "media-compressor 用の S3 バケット名"
}

output "ecr_url_media_compressor_compress_image" {
  value       = module.ecr.url_media_compressor_compress_image
  description = "media-compressor-compress-image 用 ECR リポジトリ URL"
}

output "lambda_arn_media_compressor_compress_image" {
  value       = module.lambda.arn_media_compressor_compress_image
  description = "media-compressor-compress-image Lambda ARN"
}

output "ecr_url_media_compressor_compress_video" {
  value       = module.ecr.url_media_compressor_compress_video
  description = "media-compressor-compress-video 用 ECR リポジトリ URL"
}

output "ecs_task_definition_arn_media_compressor_compress_video" {
  value       = module.ecs_task_definition.arn_media_compressor_compress_video
  description = "media-compressor-compress-video ECS task definition ARN"
}
