resource "aws_ecr_repository" "main" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_lifecycle_policy" "retain_latest_images" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "最新の${var.retained_image_count}世代のイメージのみを保持"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.retained_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
