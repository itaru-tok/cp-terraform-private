/************************************************************
Secrets Manager Read
************************************************************/
resource "aws_iam_policy" "secrets_manager_read" {
  name = "secrets-manager-readonly-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

/************************************************************
CloudWatch Logs Write
************************************************************/
resource "aws_iam_policy" "cloud_watch_logs_write" {
  name = "cloud-watch-logs-write-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

/************************************************************
ECS RunTask
************************************************************/
resource "aws_iam_policy" "ecs_run_task" {
  name = "ecs-run-task-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecs:RunTask"
        Resource = "*"
      }
    ]
  })
}

/************************************************************
PassRole to ECS Task
************************************************************/
resource "aws_iam_policy" "pass_role_to_ecs_task" {
  name = "pass-role-to-ecs-task-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

/************************************************************
ECS Write
************************************************************/
resource "aws_iam_policy" "ecs_write" {
  name = "ecs-write-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:RunTask"
        ]
        Resource = "*"
      }
    ]
  })
}

/************************************************************
RDS Start and Stop
************************************************************/
resource "aws_iam_policy" "rds_start_stop" {
  name = "rds-start-stop-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:StartDBInstance",
          "rds:StopDBInstance"
        ]
        Resource = "*"
      }
    ]
  })
}

/************************************************************
EC2 Start and Stop
************************************************************/
resource "aws_iam_policy" "ec2_start_stop" {
  name = "ec2-start-stop-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

/************************************************************
GitHub Actions
************************************************************/
resource "aws_iam_policy" "github_actions" {
  name = "github-actions-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [
          "arn:aws:ecr:${var.region}:${var.account_id}:repository/slack-metrics-${var.env}",
          "arn:aws:ecr:${var.region}:${var.account_id}:repository/db-migrator-${var.env}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:${var.region}:${var.account_id}:parameter/image-tag-slack-metrics-${var.env}",
          "arn:aws:ssm:${var.region}:${var.account_id}:parameter/image-tag-db-migrator-${var.env}",
          "arn:aws:ssm:${var.region}:${var.account_id}:parameter/ecspresso-${var.env}/*",
          "arn:aws:ssm:${var.region}:${var.account_id}:parameter/slack-${var.env}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:TagResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "application-autoscaling:DescribeScalableTargets"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}
