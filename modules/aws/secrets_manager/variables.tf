variable "env" {
  type = string
}

variable "slack_metrics_db_password_key" {
  type        = string
  description = "db-main-instance シークレット JSON 内の slack_metrics 用パスワードのキー"
  default     = "slack_metrics_password"
}

variable "slack_metrics_db_username_key" {
  type        = string
  description = "db-main-instance シークレット JSON 内のユーザー名キー（無ければ slack_metrics を既定）"
  default     = ""
}

variable "enable_datadog_keys" {
  type        = bool
  description = "Datadog 認証情報用シークレットを作成するかどうか。Datadog コース終了後はコスト削減のため false。"
  default     = true
}
