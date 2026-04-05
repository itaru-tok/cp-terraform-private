output "arn_db_main_instance" {
  value = aws_secretsmanager_secret.db_main_instance.arn
}

output "arn_argocd_github_oidc" {
  value = aws_secretsmanager_secret.argocd_github_oidc.arn
}
