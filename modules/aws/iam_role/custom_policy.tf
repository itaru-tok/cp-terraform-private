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
Parameter Store Read（Lambda 環境変数用）
************************************************************/
resource "aws_iam_policy" "parameter_store_read" {
  name = "parameter-store-read-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
        ]
        Resource = "*"
      }
    ]
  })
}

/************************************************************
SQS Read and Write
************************************************************/
resource "aws_iam_policy" "sqs_read_write" {
  name = "sqs-read-write-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "*"
      }
    ]
  })
}

/************************************************************
DB Connect（RDS IAM 認証）
************************************************************/
resource "aws_iam_policy" "db_connect" {
  name = "db-connect-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = "*"
      },
      {
        Sid    = "RDSProxyDescribe"
        Effect = "Allow"
        Action = [
          "rds:DescribeDBProxies",
          "rds:DescribeDBProxyEndpoints",
          "rds:DescribeDBProxyTargetGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

/************************************************************
EventBridge Scheduler → slack-metrics-batch Lambda
************************************************************/
resource "aws_iam_policy" "scheduler_invoke_slack_metrics_batch_lambda" {
  name = "scheduler-invoke-slack-metrics-batch-lambda-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "arn:aws:lambda:${var.region}:${var.account_id}:function:slack-metrics-batch-${var.env}"
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
cp-scheduler-slack-metrics → ECS RunTask 用 PassRole
（顧客管理ポリシー名は Step Functions 用の pass-role-to-ecs-task-${var.env} と別名）
************************************************************/
resource "aws_iam_policy" "cp_scheduler_slack_metrics_pass_role_ecs" {
  name = "cp-scheduler-slack-metrics-pass-role-ecs-${var.env}"
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
cp-scheduler-cost-cutter → ECS
（顧客管理ポリシー名は Step Functions 用の ecs-write-${var.env} と別名）
************************************************************/
resource "aws_iam_policy" "cp_scheduler_cost_cutter_ecs_write" {
  name = "cp-scheduler-cost-cutter-ecs-write-${var.env}"
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
cp-k8s-log-transfer（Fluent Bit → CloudWatch Logs / EKS Pod Identity）
************************************************************/
resource "aws_iam_policy" "cp_k8s_log_transfer" {
  name = "cp-k8s-log-transfer-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
        ]
        Resource = "*"
      }
    ]
  })
}

/************************************************************
practice-ecs-calculate（ECS タスクロール）→ Step Functions Callback API
************************************************************/
resource "aws_iam_policy" "practice_ecs_calculate_step_functions_callback" {
  name = "practice-ecs-calculate-step-functions-callback-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:SendTaskSuccess",
          "states:SendTaskFailure",
          "states:SendTaskHeartbeat",
        ]
        # タスクトークンで実行が特定されるため Resource は *（AWS 推奨パターン）
        Resource = "*"
      }
    ]
  })
}

/************************************************************
Step Functions practice → practice-lambda-calculate を起動
************************************************************/
resource "aws_iam_policy" "step_functions_practice_invoke_practice_lambda_calculate" {
  name = "step-functions-practice-invoke-practice-lambda-calculate-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        # ステート定義が function:...:$LATEST のようにバージョン付き ARN になるため、末尾 :* で全バージョン・エイリアスを許可
        Resource = "arn:aws:lambda:${var.region}:${var.account_id}:function:practice-lambda-calculate-${var.env}:*"
      }
    ]
  })
}

/************************************************************
Step Functions practice → ECS RunTask（学習用 practice-ecs-calculate）
************************************************************/
resource "aws_iam_policy" "step_functions_practice_ecs_write" {
  name = "ecs-write-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:DescribeTaskDefinition",
        ]
        Resource = "arn:aws:ecs:${var.region}:${var.account_id}:task-definition/practice-ecs-calculate-${var.env}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeClusters",
        ]
        Resource = "arn:aws:ecs:${var.region}:${var.account_id}:cluster/cloud-pratica-backend-${var.env}"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:StopTask",
          "ecs:DescribeTasks",
        ]
        Resource = "arn:aws:ecs:${var.region}:${var.account_id}:task/cloud-pratica-backend-${var.env}/*"
      },
    ]
  })
}

/************************************************************
Step Functions practice → ECS タスクへの iam:PassRole
************************************************************/
resource "aws_iam_policy" "step_functions_practice_pass_role_to_ecs_task" {
  name = "pass-role-to-ecs-task-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
        ]
        Resource = [
          aws_iam_role.ecs_task_execution.arn,
          aws_iam_role.practice_ecs_calculate.arn,
        ]
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
Step Functions media-compressor → Lambda Invoke
************************************************************/
resource "aws_iam_policy" "step_functions_media_compressor_invoke_lambda" {
  name = "step-functions-media-compressor-invoke-lambda-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "*"
      }
    ]
  })
}

/************************************************************
Step Functions media-compressor → ECS
実行対象のタスク定義・クラスターは後続の実装で絞り込めるように、いったん汎用で許可
************************************************************/
resource "aws_iam_policy" "step_functions_media_compressor_ecs_write" {
  name = "step-functions-media-compressor-ecs-write-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeClusters",
          "ecs:StopTask",
          "ecs:DescribeTasks",
        ]
        Resource = "*"
      }
    ]
  })
}

/************************************************************
Step Functions media-compressor → ECS タスクへの iam:PassRole
************************************************************/
resource "aws_iam_policy" "step_functions_media_compressor_pass_role_to_ecs_task" {
  name = "step-functions-media-compressor-pass-role-to-ecs-task-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
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

/************************************************************
media-compressor-compress-image → S3 Read/Write
************************************************************/
resource "aws_iam_policy" "media_compressor_compress_image_s3" {
  name = "media-compressor-compress-image-s3-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Resource = length(trimspace(var.media_compressor_bucket_arn)) > 0 ? "${var.media_compressor_bucket_arn}/*" : "*"
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
          "arn:aws:ecr:${var.region}:${var.account_id}:repository/slack-metrics-lambda-${var.env}",
          "arn:aws:ecr:${var.region}:${var.account_id}:repository/db-migrator-${var.env}",
          "arn:aws:ecr:${var.region}:${var.account_id}:repository/practice-lambda-calculate-${var.env}",
          "arn:aws:ecr:${var.region}:${var.account_id}:repository/practice-ecs-calculate-${var.env}"
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
