output "endpoint" {
  value       = aws_db_proxy.cloud_pratica.endpoint
  description = "RDS Proxy 接続用エンドポイント（アプリのホストに利用）"
}

output "arn" {
  value = aws_db_proxy.cloud_pratica.arn
}

output "name" {
  value = aws_db_proxy.cloud_pratica.name
}
