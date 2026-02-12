variable "env" {
  type = string
}

variable "slack_metrics" {
  type = object({
    cloudfront_distribution_arn = optional(string)
  })
  default = {
    cloudfront_distribution_arn = null
  }
}
