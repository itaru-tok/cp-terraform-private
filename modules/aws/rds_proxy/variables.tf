variable "env" {
  type = string
}

variable "db_proxy_name" {
  type        = string
  description = "RDS Proxy 名（例: cloud-pratica-stg）。import 時の ID と一致させる"
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "RDS Proxy を配置するプライベートサブネット ID"
}

variable "rds_proxy_security_group_id" {
  type = string
}

variable "secrets_manager_secret_arn" {
  type        = string
  description = "認証情報 JSON を格納した Secrets Manager シークレットの ARN（POSTGRESQL + SECRETS 認証）"
}

variable "iam_role_arn_rds_proxy" {
  type        = string
  description = "Secrets Manager を読む IAM ロール（cp-rds-proxy）の ARN"
}

variable "db_instance_identifier" {
  type        = string
  description = "プロキシのターゲットとする RDS インスタンス identifier（例: cloud-pratica-stg）"
}

variable "require_tls" {
  type        = bool
  default     = true
  description = "クライアント接続に TLS を要求するか"
}

variable "connection_borrow_timeout" {
  type        = number
  default     = 120
  description = "aws_db_proxy_default_target_group の connection_borrow_timeout（秒）"
}

variable "max_connections_percent" {
  type        = number
  default     = 50
  description = "新規作成時のみ参照。import 済みは lifecycle で pool を追跡しない"
}

variable "max_idle_connections_percent" {
  type        = number
  default     = 25
  description = "新規作成時のみ参照。import 済みは lifecycle で pool を追跡しない"
}
