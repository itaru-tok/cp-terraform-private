/************************************************************
slack metrics api
************************************************************/
resource "aws_ecs_task_definition" "slack_metrics_api" {
  family                   = "slack-metrics-api-${var.env}"
  cpu                      = var.ecs_task_specs.slack_metrics_api.cpu
  memory                   = var.ecs_task_specs.slack_metrics_api.memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn_slack_metrics
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name  = "api"
      image = var.ecr_url_slack_metrics
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          name          = "api-8080-tcp"
          appProtocol   = "http"
        }
      ]
      essential = true
      environmentFiles = [
        {
          type  = "s3"
          value = "${var.arn_cp_config_bucket}/slack-metrics-${var.env}.env"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/api/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 0
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/slack-metrics-api-${var.env}"
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
      secrets = [
        {
          name      = "POSTGRES_MAIN_HOST"
          valueFrom = "${var.secrets_manager_arn_db_main_instance}:host::"
        },
        {
          name      = "POSTGRES_MAIN_PASSWORD"
          valueFrom = "${var.secrets_manager_arn_db_main_instance}:operator_password::"
        },
        {
          name      = "POSTGRES_MAIN_USER"
          valueFrom = "${var.secrets_manager_arn_db_main_instance}:operator_user::"
        }
      ]
    }
  ])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

/************************************************************
slack metrics batch
************************************************************/
resource "aws_ecs_task_definition" "slack_metrics_batch" {
  family                   = "slack-metrics-batch-${var.env}"
  cpu                      = var.ecs_task_specs.slack_metrics_batch.cpu
  memory                   = var.ecs_task_specs.slack_metrics_batch.memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn_slack_metrics
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.ecr_url_slack_metrics
      essential = true
      environment = [
        {
          name  = "MODE"
          value = "batch"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/slack-metrics-batch-${var.env}"
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
      readonlyRootFilesystem = true
    }
  ])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

/************************************************************
DB Migration
************************************************************/
resource "aws_ecs_task_definition" "db_migrator" {
  family                   = "db-migrator-${var.env}"
  cpu                      = var.ecs_task_specs.db_migrator.cpu
  memory                   = var.ecs_task_specs.db_migrator.memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn_db_migrator
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.ecr_url_db_migrator
      essential = true
      environmentFiles = [
        {
          type  = "s3"
          value = "${var.arn_cp_config_bucket}/db-migrator-${var.env}.env"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/db-migrator-${var.env}"
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
      secrets = [
        {
          name      = "DB_HOST"
          valueFrom = "${var.secrets_manager_arn_db_main_instance}:host::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.secrets_manager_arn_db_main_instance}:operator_password::"
        },
        {
          name      = "DB_USER"
          valueFrom = "${var.secrets_manager_arn_db_main_instance}:operator_user::"
        }
      ]
    }
  ])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  lifecycle {
    ignore_changes = [container_definitions]
  }
}
