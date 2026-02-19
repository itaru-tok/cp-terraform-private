/************************************************************
Slack Metrics
************************************************************/
resource "aws_scheduler_schedule_group" "slack_metrics" {
  name = "slack-metrics-${var.env}"
  tags = {
    Env = var.env
  }
}

resource "aws_scheduler_schedule" "sync_workspaces" {
  name       = "sync-workspaces-${var.env}"
  group_name = aws_scheduler_schedule_group.slack_metrics.name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 1 * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"
  state                        = "ENABLED"

  target {
    role_arn = var.slack_metrics.iam_role_arn
    arn      = var.slack_metrics.ecs_cluster_arn

    ecs_parameters {
      enable_ecs_managed_tags = true
      launch_type             = "FARGATE"
      task_definition_arn     = var.slack_metrics.ecs_task_definition_arn_without_revision

      network_configuration {
        assign_public_ip = false
        security_groups  = [var.slack_metrics.security_group_id]
        subnets          = var.private_subnet_ids
      }
    }

    input = jsonencode({
      containerOverrides = [
        {
          name = "batch"
          environment = [
            {
              name  = "TYPE"
              value = "sync-workspaces"
            },
            {
              name  = "MODE"
              value = "batch"
            }
          ]
        }
      ]
    })

    retry_policy {
      maximum_event_age_in_seconds = 10800
      maximum_retry_attempts       = 3
    }
  }
}

/************************************************************
Cost Cutter
************************************************************/
resource "aws_scheduler_schedule_group" "cost_cutter" {
  name = "cost-cutter-${var.env}"
  tags = {
    Env = var.env
  }
}

resource "aws_scheduler_schedule" "start_db_instance_cp" {
  group_name  = aws_scheduler_schedule_group.cost_cutter.name
  name        = "start-db-instance-cp-${var.env}"
  description = "Cloud PraticaのDBインスタンスを毎週月曜日の深夜12時45分に起動する。(RDSでは7日以上の停止ができないため)"

  schedule_expression          = "cron(45 0 ? * 2 *)"
  schedule_expression_timezone = "Asia/Tokyo"
  state                        = var.cost_cutter.enable ? "ENABLED" : "DISABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBInstance"
    role_arn = var.cost_cutter.iam_role_arn

    input = jsonencode({
      DbInstanceIdentifier = "cloud-pratica-${var.env}"
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

resource "aws_scheduler_schedule" "stop_db_instance_cp" {
  group_name  = aws_scheduler_schedule_group.cost_cutter.name
  name        = "stop-db-instance-cp-${var.env}"
  description = "Cloud PraticaのDBインスタンスを毎日深夜1時に停止する。"

  schedule_expression          = "cron(0 1 * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"
  state                        = var.cost_cutter.enable ? "ENABLED" : "DISABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
    role_arn = var.cost_cutter.iam_role_arn

    input = jsonencode({
      DbInstanceIdentifier = "cloud-pratica-${var.env}"
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

resource "aws_scheduler_schedule" "stop_ec2_instances" {
  group_name  = aws_scheduler_schedule_group.cost_cutter.name
  name        = "stop-ec2-instances-${var.env}"
  description = "AWSアカウント内の全てのEC2インスタンスを毎日深夜1時に停止する。"

  schedule_expression          = "cron(0 1 * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"
  state                        = var.cost_cutter.enable ? "ENABLED" : "DISABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = var.cost_cutter.iam_role_arn

    input = jsonencode({
      InstanceIds = var.cost_cutter.ec2_instance_ids
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

resource "aws_scheduler_schedule" "scale_in_ecs_service_slack_metrics_api" {
  group_name  = aws_scheduler_schedule_group.cost_cutter.name
  name        = "scale-in-ecs-service-slack-metrics-api-${var.env}"
  description = "ECSサービス slack-metrics-api のタスク数を毎日深夜1時に0にする。"

  schedule_expression          = "cron(0 1 * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"
  state                        = var.cost_cutter.enable ? "ENABLED" : "DISABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = var.cost_cutter.iam_role_arn

    input = jsonencode({
      Cluster      = var.cost_cutter.ecs_cluster_arn_cloud_pratica_backend
      DesiredCount = 0
      Service      = "slack-metrics-api-${var.env}"
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}
