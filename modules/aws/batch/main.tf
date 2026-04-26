/************************************************************
Compute Environments
************************************************************/
resource "aws_batch_compute_environment" "fargate" {
  name         = "fargate-${var.env}"
  type         = "MANAGED"
  state        = "ENABLED"
  service_role = "arn:aws:iam::${var.account_id}:role/aws-service-role/batch.amazonaws.com/AWSServiceRoleForBatch"

  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 256
    subnets            = var.private_subnet_ids
    security_group_ids = [var.slack_metrics.security_group_id]
  }
}

resource "aws_batch_compute_environment" "fargate_spot" {
  name         = "fargate-spot-${var.env}"
  type         = "MANAGED"
  state        = "ENABLED"
  service_role = "arn:aws:iam::${var.account_id}:role/aws-service-role/batch.amazonaws.com/AWSServiceRoleForBatch"

  compute_resources {
    type               = "FARGATE_SPOT"
    max_vcpus          = 256
    subnets            = var.private_subnet_ids
    security_group_ids = [var.slack_metrics.security_group_id]
  }
}

/************************************************************
Job Queue
************************************************************/
resource "aws_batch_job_queue" "slack_metrics" {
  name     = "slack-metrics-${var.env}"
  state    = "ENABLED"
  priority = 0

  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.fargate_spot.arn
  }

  compute_environment_order {
    order               = 2
    compute_environment = aws_batch_compute_environment.fargate.arn
  }

  job_state_time_limit_action {
    action           = "CANCEL"
    max_time_seconds = 600
    reason           = "CAPACITY:INSUFFICIENT_INSTANCE_CAPACITY"
    state            = "RUNNABLE"
  }
}

/************************************************************
Job Definition（Terraform 管理外：バックエンドの JSON + CI/CD で登録）
常に最新リビジョンを参照するため data source で解決する
************************************************************/
data "aws_batch_job_definition" "slack_metrics" {
  name = "slack-metrics-${var.env}"
}
