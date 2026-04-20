module "ecr_db_migrator" {
  source = "../ecr_unit"
  name   = "db-migrator-${var.env}"
}

module "ecr_slack_metrics" {
  source = "../ecr_unit"
  name   = "slack-metrics-${var.env}"
}

module "ecr_slack_metrics_lambda" {
  source = "../ecr_unit"
  name   = "slack-metrics-lambda-${var.env}"
}

// Step Functions 学習用（practice / Calculate Lambda コンテナ）
module "ecr_practice_lambda_calculate" {
  source = "../ecr_unit"
  name   = "practice-lambda-calculate-${var.env}"
}

// Step Functions 学習用（practice / Calculate ECS タスク コンテナ）
module "ecr_practice_ecs_calculate" {
  source = "../ecr_unit"
  name   = "practice-ecs-calculate-${var.env}"
}

module "ecr_media_compressor_compress_image" {
  source = "../ecr_unit"
  name   = "media-compressor-compress-image-${var.env}"
}

module "ecr_media_compressor_compress_video" {
  source = "../ecr_unit"
  name   = "media-compressor-compress-video-${var.env}"
}

module "ecr_media_compressor_notify_result" {
  source = "../ecr_unit"
  name   = "media-compressor-notify-result-${var.env}"
}
