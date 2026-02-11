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

resource "aws_appautoscaling_target" "slack_metrics_api" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cloud_pratica_backend.name}/${aws_ecs_service.slack_metrics_api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags               = {}

  lifecycle {
    ignore_changes = [tags_all]
  }

  depends_on = [aws_ecs_service.slack_metrics_api]
}

resource "aws_appautoscaling_policy" "slack_metrics_api_cpu" {
  name               = "target-tracking-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.slack_metrics_api.resource_id
  scalable_dimension = aws_appautoscaling_target.slack_metrics_api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.slack_metrics_api.service_namespace

  target_tracking_scaling_policy_configuration {
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
    target_value       = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "slack_metrics_api_memory" {
  name               = "target-tracking-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.slack_metrics_api.resource_id
  scalable_dimension = aws_appautoscaling_target.slack_metrics_api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.slack_metrics_api.service_namespace

  target_tracking_scaling_policy_configuration {
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value       = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}
