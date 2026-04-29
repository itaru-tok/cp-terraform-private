locals {
  cost_api_datadog_enabled = var.secrets_manager_arn_datadog_keys != null
  cost_api_dd_secret       = local.cost_api_datadog_enabled ? "${var.secrets_manager_arn_datadog_keys}:api_key::" : null

  cost_api_dd_api_key_secret = [
    { name = "DD_API_KEY", valueFrom = local.cost_api_dd_secret }
  ]

  cost_api_firelens_log_configuration = {
    logDriver = "awsfirelens"
    options = {
      Name           = "datadog"
      Host           = "http-intake.logs.ap1.datadoghq.com"
      TLS            = "on"
      provider       = "ecs"
      dd_source      = "ecs"
      dd_message_key = "msg"
    }
    secretOptions = [{ name = "apikey", valueFrom = local.cost_api_dd_secret }]
  }

  cost_api_awslogs_log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "/ecs/cost-api-${var.env}"
      awslogs-create-group  = "true"
      awslogs-region        = "ap-northeast-1"
      awslogs-stream-prefix = "ecs"
    }
  }
}

resource "aws_ecs_task_definition" "cost_api" {
  # MEMO: Datadog コース終了後 datadog_keys シークレットを削除すると container_definitions に
  # diff が出てリビジョンが再作成されるため、既存リビジョンは凍結する。
  lifecycle {
    ignore_changes = [container_definitions]
  }

  family                   = "cost-api-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.ecs_task_specs.cost_api.cpu)
  memory                   = tostring(var.ecs_task_specs.cost_api.memory)
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn_cost_api

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode(concat([
    merge({
      name      = "cost-aggregator"
      image     = var.ecr_url_cost_aggregator
      essential = true
      portMappings = [
        { containerPort = 8080, hostPort = 8080, protocol = "tcp", name = "8080", appProtocol = "http" }
      ]
      environmentFiles = [
        { value = "${var.arn_cp_config_bucket}/cost-aggregator-${var.env}.env", type = "s3" }
      ]
      logConfiguration = jsondecode(local.cost_api_datadog_enabled ? jsonencode(merge(local.cost_api_firelens_log_configuration, {
        options = merge(local.cost_api_firelens_log_configuration.options, {
          dd_service = "cost-aggregator"
          dd_tags    = "service:cost-aggregator,env:${var.env}"
        })
      })) : jsonencode(local.cost_api_awslogs_log_configuration))
      healthCheck = {
        command  = ["CMD-SHELL", "curl -f http://localhost:8080/api/health || exit 1"]
        interval = 30
        timeout  = 5
        retries  = 3
      }
      cpu            = 0
      environment    = []
      mountPoints    = []
      volumesFrom    = []
      systemControls = []
      }, local.cost_api_datadog_enabled ? {
      secrets   = local.cost_api_dd_api_key_secret
      dependsOn = [{ containerName = "datadog-agent", condition = "HEALTHY" }]
    } : {}),
    merge({
      name      = "cost-provider"
      image     = var.ecr_url_cost_provider
      essential = true
      portMappings = [
        { containerPort = 50051, hostPort = 50051, protocol = "tcp", name = "50051", appProtocol = "grpc" }
      ]
      environmentFiles = [
        { value = "${var.arn_cp_config_bucket}/cost-provider-${var.env}.env", type = "s3" }
      ]
      logConfiguration = jsondecode(local.cost_api_datadog_enabled ? jsonencode(merge(local.cost_api_firelens_log_configuration, {
        options = merge(local.cost_api_firelens_log_configuration.options, {
          dd_service = "cost-provider"
          dd_tags    = "service:cost-provider,env:${var.env}"
        })
      })) : jsonencode(local.cost_api_awslogs_log_configuration))
      healthCheck = {
        command  = ["CMD-SHELL", "ps aux grep main | grep -v grep || exit 1"]
        interval = 30
        timeout  = 5
        retries  = 3
      }
      cpu            = 0
      environment    = []
      mountPoints    = []
      volumesFrom    = []
      systemControls = []
      }, local.cost_api_datadog_enabled ? {
      secrets   = local.cost_api_dd_api_key_secret
      dependsOn = [{ containerName = "datadog-agent", condition = "HEALTHY" }]
    } : {}),
    ], [for container in [
      {
        name      = "datadog-agent"
        image     = "public.ecr.aws/datadog/agent:latest"
        essential = true
        environmentFiles = [
          { value = "${var.arn_cp_config_bucket}/datadog-agent-${var.env}.env", type = "s3" }
        ]
        secrets = [{ name = "DD_API_KEY", valueFrom = local.cost_api_dd_secret }]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/cost-api-${var.env}"
            awslogs-create-group  = "true"
            awslogs-region        = "ap-northeast-1"
            awslogs-stream-prefix = "ecs"
          }
          secretOptions = []
        }
        healthCheck = {
          command     = ["CMD-SHELL", "agent health"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 15
        }
        cpu            = 0
        environment    = []
        portMappings   = []
        mountPoints    = []
        volumesFrom    = []
        systemControls = []
      },
      {
        name              = "log-router"
        image             = "public.ecr.aws/aws-observability/aws-for-fluent-bit:stable"
        essential         = true
        memoryReservation = 51
        user              = "0"
        firelensConfiguration = {
          type = "fluentbit"
          options = {
            config-file-type        = "file"
            config-file-value       = "/fluent-bit/configs/parse-json.conf"
            enable-ecs-log-metadata = "true"
          }
        }
        cpu            = 0
        environment    = []
        portMappings   = []
        mountPoints    = []
        volumesFrom    = []
        systemControls = []
      }
  ] : container if local.cost_api_datadog_enabled]))
}

resource "aws_ecs_task_definition" "media_compressor_compress_video" {
  family                   = "media-compressor-compress-video-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.ecs_task_specs.media_compressor_compress_video.cpu)
  memory                   = tostring(var.ecs_task_specs.media_compressor_compress_video.memory)
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn_media_compressor_compress_video

  container_definitions = jsonencode([
    {
      name      = "media-compressor-compress-video"
      image     = var.ecr_url_media_compressor_compress_video
      essential = true
      environment = [
        {
          name  = "MODE"
          value = "ecs"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/media-compressor-compress-video-${var.env}"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}
