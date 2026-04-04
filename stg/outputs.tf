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
