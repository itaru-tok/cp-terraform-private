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
