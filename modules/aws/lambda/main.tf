/************************************************************
slack-metrics-api（コンテナ Lambda / VPC）
参考: cloud-pratica-terraform/modules/aws/lambda/main.tf
************************************************************/
resource "aws_lambda_function" "slack_metrics_api" {
  function_name = "slack-metrics-api-${var.env}"
  role          = var.slack_metrics.role_arn
  image_uri     = var.slack_metrics.image_uri
  package_type  = "Image"
  description   = "Slack MetricsのAPIとなるLambda関数"
  memory_size   = 256
  timeout       = 60

  environment {
    variables = {
      ENV  = var.env
      MODE = "api"
    }
  }

  vpc_config {
    ipv6_allowed_for_dual_stack = false
    security_group_ids = [
      var.slack_metrics.security_group_id
    ]
    subnet_ids = var.private_subnet_ids
  }

  lifecycle {
    ignore_changes = [image_uri]
  }
}

# API Gateway モジュール追加後に api_gateway_id を渡す
resource "aws_lambda_permission" "api_gateway_slack_metrics_api" {
  count = var.slack_metrics.api_gateway_id != null ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_metrics_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.aws_account_id}:${var.slack_metrics.api_gateway_id}/*/*/*"
}
