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
