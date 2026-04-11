output "invoke_arn_slack_metrics_api" {
  value = aws_lambda_function.slack_metrics_api.invoke_arn
}

output "arn_slack_metrics_api" {
  value = aws_lambda_function.slack_metrics_api.arn
}

output "function_name_slack_metrics_api" {
  value = aws_lambda_function.slack_metrics_api.function_name
}

output "arn_slack_metrics_batch" {
  value = aws_lambda_function.slack_metrics_batch.arn
}

output "arn_slack_metrics_worker" {
  value = aws_lambda_function.slack_metrics_worker.arn
}
