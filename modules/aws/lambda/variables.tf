variable "env" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "region" {
  type        = string
  description = "execute-api の ARN 用（通常は ap-northeast-1）"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "slack_metrics" {
  type = object({
    role_arn          = string
    image_uri         = string
    security_group_id = string
    api_gateway_id    = optional(string)
    sqs_arn           = optional(string)
  })
}

variable "practice_lambda_calculate" {
  type = object({
    role_arn  = string
    image_uri = string
  })
  default     = null
  description = "Step Functions 学習用 Calculate Lambda（コンテナ）。null のときリソースを作らない"
}

variable "media_compressor_compress_image" {
  type = object({
    role_arn  = string
    image_uri = string
  })
  default     = null
  description = "media-compressor の CompressImage Lambda（コンテナ）。null のときリソースを作らない"
}

variable "media_compressor_notify_result" {
  type = object({
    role_arn        = string
    image_uri       = string
    slack_bot_token = string
  })
  default     = null
  description = "media-compressor の NotifyResult Lambda（コンテナ）。null のときリソースを作らない"
}

variable "media_compressor_invoker" {
  type = object({
    role_arn          = string
    image_uri         = string
    state_machine_arn = string
  })
  default     = null
  description = "S3 イベントから media-compressor Step Functions を起動する Invoker Lambda（コンテナ）。null のときリソースを作らない"
}
