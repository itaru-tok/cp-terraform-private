variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "certificate_arn" {
  type = string
}

variable "tg_slack_metrics_api_arn" {
  type = string
}

variable "sg_alb_id" {
  type = string
}
