resource "aws_ecs_cluster" "cloud_pratica_backend" {
  name = "cloud-pratica-backend-${var.env}"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  tags = {
    Env = var.env
  }
}

resource "aws_ecs_cluster_capacity_providers" "cloud_pratica_backend" {
  cluster_name       = aws_ecs_cluster.cloud_pratica_backend.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

resource "aws_ecs_service" "slack_metrics_api" {
  cluster                            = aws_ecs_cluster.cloud_pratica_backend.arn
  name                               = var.slack_metrics_api.name
  task_definition                    = var.slack_metrics_api.task_definition
  desired_count                      = 1
  enable_execute_command             = var.slack_metrics_api.enable_execute_command
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds  = 0
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  capacity_provider_strategy {
    base              = 0
    capacity_provider = var.slack_metrics_api.capacity_provider
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  dynamic "load_balancer" {
    for_each = var.slack_metrics_api.target_group_arn != null ? [1] : []
    content {
      container_name   = "api"
      container_port   = 8080
      target_group_arn = var.slack_metrics_api.target_group_arn
    }
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = var.slack_metrics_api.security_group_ids
    subnets          = var.slack_metrics_api.subnet_ids
  }

  lifecycle {
    ignore_changes = [
      # MEMO: コスト削減で落とすタイミングがあるため
      desired_count,
      # MEMO: ecspressoからタスク定義のリビジョンを更新するため
      task_definition,
    ]
  }
}
