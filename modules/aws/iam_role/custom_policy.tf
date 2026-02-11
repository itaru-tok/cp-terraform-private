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
