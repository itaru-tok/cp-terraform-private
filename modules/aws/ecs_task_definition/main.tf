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
