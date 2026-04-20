output "slack_bot_token" {
  value     = aws_ssm_parameter.slack_bot_token.value
  sensitive = true
}
