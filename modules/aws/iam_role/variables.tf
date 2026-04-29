variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "rds_proxy_secret_arn" {
  type        = string
  default     = ""
  description = "RDS Proxy 利用時のみ: Secrets Manager の ARN（例: db_slack_metrics_rds_proxy）。空なら cp-rds-proxy 用インラインポリシーは作らない"
}

variable "media_compressor_bucket_arn" {
  type        = string
  default     = ""
  description = "media-compressor 用 S3 バケット ARN。空なら Lambda 用 S3 ポリシーは広めに作成される"
}

variable "audit_log_bucket_arn" {
  type        = string
  default     = ""
  description = "監査ログ Firehose 宛先の S3 バケット ARN。空のとき cp-audit-log-firehose ロールは作らない"
}

variable "audit_log_firehose_transform_function_name" {
  type        = string
  default     = ""
  description = "Firehose レコード変換用 Lambda の関数名（省略時 firehose-cwlogs-transformer-{env}）"
}

variable "slack_metrics_cwl_firehose_delivery_stream_name" {
  type        = string
  default     = ""
  description = "slack-metrics-api ログの CWL サブスクリプション宛先 Firehose 名。空なら audit-log-slack-metrics-{env}"
}

variable "audit_log_glue_database_name" {
  type        = string
  default     = ""
  description = "監査ログ Glue Data Catalog のデータベース名（Firehose の Parquet 変換で参照）。空なら audit_log_{env}"
}

variable "datadog_external_id" {
  type        = string
  default     = null
  description = "Datadog AWS Integration の External ID。null のとき DatadogIntegrationRole は作らない"
}

variable "datadog_permission_chunks" {
  type        = list(list(string))
  default     = []
  description = "Datadog 統合用 IAM Policy のチャンク（Policyドキュメントの 6144 byte 制限を回避するため呼び出し側で分割）"
}

variable "datadog_aws_account_id" {
  type        = string
  default     = "417141415827"
  description = "Datadog の AWS アカウント ID。AP1 site = 417141415827"
}
