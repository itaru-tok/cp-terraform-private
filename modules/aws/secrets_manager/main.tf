resource "aws_secretsmanager_secret" "db_main_instance" {
  name = "db-main-instance-${var.env}"
}

# Argo CD（dex）GitHub OAuth: client_id / client_secret を JSON で保持。初回プレースホルダー後はコンソール等で更新し、Terraform は secret_string を変更しない
resource "aws_secretsmanager_secret" "argocd_github_oidc" {
  name = "argocd-github-oidc-${var.env}"
}

resource "aws_secretsmanager_secret_version" "argocd_github_oidc" {
  secret_id = aws_secretsmanager_secret.argocd_github_oidc.id
  secret_string = jsonencode({
    client_id     = "REPLACE_ME"
    client_secret = "REPLACE_ME"
  })
  lifecycle {
    ignore_changes = [secret_string]
  }
}
