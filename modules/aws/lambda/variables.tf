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
