variable "aws_account_id" {
  type = string
}

variable "namespace_filters_include_only" {
  type        = list(string)
  default     = ["AWS/EC2", "AWS/RDS", "AWS/ECS"]
  description = "コスト削減のため、収集対象の AWS namespace を絞る"
}

variable "iam_policy_target_chunk_size" {
  type        = number
  default     = 5900
  description = "IAM policy のサイズ上限 6144 バイトに対するチャンクの目標サイズ"
}
