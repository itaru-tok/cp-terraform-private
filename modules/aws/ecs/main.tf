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

resource "aws_appautoscaling_target" "slack_metrics_api" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cloud_pratica_backend.name}/${var.slack_metrics_api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags               = {}

  lifecycle {
    ignore_changes = [tags_all]
  }
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

resource "aws_ecs_service" "cost_api" {
  name                   = var.cost_api.name
  cluster                = aws_ecs_cluster.cloud_pratica_backend.id
  task_definition        = var.cost_api.task_definition
  desired_count          = 1
  enable_execute_command = var.cost_api.enable_execute_command
  propagate_tags         = "SERVICE"

  capacity_provider_strategy {
    capacity_provider = var.cost_api.capacity_provider
    weight            = 1
  }

  network_configuration {
    subnets          = var.cost_api.subnet_ids
    security_groups  = var.cost_api.security_group_ids
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.cost_api.target_group_arn != null ? [1] : []
    content {
      target_group_arn = var.cost_api.target_group_arn
      container_name   = "cost-aggregator"
      container_port   = 8080
    }
  }

  tags = {
    GuardDutyManaged = "false"
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}
