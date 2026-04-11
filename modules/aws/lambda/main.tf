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

resource "aws_lambda_function" "slack_metrics_batch" {
  function_name = "slack-metrics-batch-${var.env}"
  role          = var.slack_metrics.role_arn
  image_uri     = var.slack_metrics.image_uri
  package_type  = "Image"
  description   = "Slack MetricsのBatchとなるLambda関数"
  memory_size   = 1024
  timeout       = 900

  environment {
    variables = {
      ENV  = var.env
      MODE = "batch"
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

resource "aws_lambda_function" "slack_metrics_worker" {
  function_name = "slack-metrics-worker-${var.env}"
  role          = var.slack_metrics.role_arn
  image_uri     = var.slack_metrics.image_uri
  package_type  = "Image"
  description   = "Slack Metricsの非同期WorkerとなるLambda関数"
  memory_size   = 1024
  timeout       = 900

  environment {
    variables = {
      ENV  = var.env
      MODE = "sqs"
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

resource "aws_lambda_event_source_mapping" "slack_metrics_worker" {
  count            = var.slack_metrics.sqs_arn != null ? 1 : 0
  event_source_arn = var.slack_metrics.sqs_arn
  function_name    = aws_lambda_function.slack_metrics_worker.function_name
  batch_size       = 10
  enabled          = true
}

resource "aws_lambda_permission" "scheduler_sync_workspaces_v3" {
  statement_id  = "AllowExecutionFromEventBridgeScheduler"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_metrics_batch.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = "arn:aws:scheduler:${var.region}:${var.aws_account_id}:schedule/slack-metrics-${var.env}/sync-workspaces-v3-${var.env}"
}

resource "aws_lambda_permission" "api_gateway_slack_metrics_api" {
  count = var.slack_metrics.api_gateway_id != null ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_metrics_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.aws_account_id}:${var.slack_metrics.api_gateway_id}/*/*/*"
}
