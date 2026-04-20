
/************************************************************
slack-metrics-backend
************************************************************/
resource "aws_iam_role" "cp_slack_metrics_backend" {
  name = "cp-slack-metrics-backend-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
      ,
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_slack_metrics_backend" {
  for_each = {
    cloudwatch = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    ses        = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
    sqs        = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
    ssm_core   = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  role       = aws_iam_role.cp_slack_metrics_backend.name
  policy_arn = each.value
}

/************************************************************
cp-slack-metrics-lambda（コンテナ Lambda / VPC）
SES はカリキュラム都合で付与しない。VPC 用に AWSLambdaVPCAccessExecutionRole。
************************************************************/
resource "aws_iam_role" "cp_slack_metrics_lambda" {
  name = "cp-slack-metrics-lambda-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_slack_metrics_lambda" {
  for_each = {
    cloudwatch      = aws_iam_policy.cloud_watch_logs_write.arn
    parameter_store = aws_iam_policy.parameter_store_read.arn
    sqs             = aws_iam_policy.sqs_read_write.arn
    secrets_manager = aws_iam_policy.secrets_manager_read.arn
    rds_db_connect  = aws_iam_policy.db_connect.arn
    vpc_access      = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
    ecr_readonly    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  role       = aws_iam_role.cp_slack_metrics_lambda.name
  policy_arn = each.value
}

/************************************************************
cp-rds-proxy（RDS Proxy が Secrets Manager の認証情報を読む）
************************************************************/
resource "aws_iam_role" "cp_rds_proxy" {
  name = "cp-rds-proxy-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cp_rds_proxy_secrets" {
  # RDS Proxy + Secrets を使うときだけ ARN を渡す。空・空白・null のときは作らない
  # （coalesce("", "") は Terraform でエラーになるため trimspace + try を使う）
  count = length(trimspace(try(var.rds_proxy_secret_arn, ""))) > 0 ? 1 : 0

  name = "rds-proxy-read-db-slack-metrics-secret"
  role = aws_iam_role.cp_rds_proxy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.rds_proxy_secret_arn
      }
    ]
  })
}

/************************************************************
cp-bastion
************************************************************/
resource "aws_iam_role" "cp_bastion" {
  name = "cp-bastion-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_bastion" {
  for_each = {
    ssm_core = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  role       = aws_iam_role.cp_bastion.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "cp_bastion" {
  name = "cp-bastion-${var.env}"
  role = aws_iam_role.cp_bastion.name
}

/************************************************************
cp-db-migrator
************************************************************/
resource "aws_iam_role" "cp_db_migrator" {
  name = "cp-db-migrator-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
      },
    ]
  })
}

/************************************************************
cp-nat
************************************************************/
resource "aws_iam_role" "cp_nat" {
  name = "cp-nat-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_nat" {
  for_each = {
    ssm_core = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  role       = aws_iam_role.cp_nat.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "cp_nat" {
  name = "cp-nat-${var.env}"
  role = aws_iam_role.cp_nat.name
}

/************************************************************
ecs-task-execution
************************************************************/
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  for_each = {
    task_execution  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    secrets_manager = aws_iam_policy.secrets_manager_read.arn
    s3              = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    cloudwatch      = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  }

  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = each.value
}

/************************************************************
Kubernetes クラスターロール（EKS コントロールプレーン）
************************************************************/
resource "aws_iam_role" "cp_k8s_cluster" {
  name = "cp-k8s-cluster-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_k8s_cluster" {
  role       = aws_iam_role.cp_k8s_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

/************************************************************
Kubernetes ノードロール（EKS ワーカー）
************************************************************/
resource "aws_iam_role" "cp_k8s_node" {
  name = "cp-k8s-node-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_k8s_node" {
  for_each = {
    eks_node = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    eks_cni  = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ecr      = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  role       = aws_iam_role.cp_k8s_node.name
  policy_arn = each.value
}

/************************************************************
cp-k8s-eso (External Secrets Operator / EKS Pod Identity)
************************************************************/
resource "aws_iam_role" "cp_k8s_eso" {
  name = "cp-k8s-eso-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_k8s_eso" {
  role       = aws_iam_role.cp_k8s_eso.name
  policy_arn = aws_iam_policy.secrets_manager_read.arn
}

/************************************************************
cp-k8s-alb-controller (AWS Load Balancer Controller / EKS Pod Identity)
公式 IAM ポリシーは v2.13.1 相当（Helm chart 1.13.x / Controller v2.13 系と整合）。更新手順: 同 URL の該当タグの iam_policy.json を取得して差し替え。
************************************************************/
resource "aws_iam_policy" "cp_k8s_alb_controller" {
  name   = "cp-k8s-alb-controller-${var.env}"
  policy = file("${path.module}/alb_controller_iam_policy.json")
}

resource "aws_iam_role" "cp_k8s_alb_controller" {
  name = "cp-k8s-alb-controller-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_k8s_alb_controller" {
  role       = aws_iam_role.cp_k8s_alb_controller.name
  policy_arn = aws_iam_policy.cp_k8s_alb_controller.arn
}

/************************************************************
cp-k8s-ebs-csi-driver (AWS EBS CSI Driver / EKS Pod Identity)
************************************************************/
resource "aws_iam_role" "cp_k8s_ebs_csi_driver" {
  name = "cp-k8s-ebs-csi-driver-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_k8s_ebs_csi_driver" {
  role       = aws_iam_role.cp_k8s_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

/************************************************************
cp-argocd-image-updater (Argo CD Image Updater / EKS Pod Identity → ECR 読み取り)
************************************************************/
resource "aws_iam_role" "cp_argocd_image_updater" {
  name = "cp-argocd-image-updater-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_argocd_image_updater" {
  role       = aws_iam_role.cp_argocd_image_updater.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

/************************************************************
cp-k8s-log-transfer（Fluent Bit / aws-for-fluent-bit → CloudWatch Logs / EKS Pod Identity）
************************************************************/
resource "aws_iam_role" "cp_k8s_log_transfer" {
  name = "cp-k8s-log-transfer-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_k8s_log_transfer" {
  role       = aws_iam_role.cp_k8s_log_transfer.name
  policy_arn = aws_iam_policy.cp_k8s_log_transfer.arn
}

/************************************************************
cp-slack-metrics-client
************************************************************/
resource "aws_iam_role" "cp_slack_metrics_client" {
  name = "cp-slack-metrics-client-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_slack_metrics_client" {
  for_each = {
    cloudwatch = aws_iam_policy.cloud_watch_logs_write.arn
  }

  role       = aws_iam_role.cp_slack_metrics_client.name
  policy_arn = each.value
}

/************************************************************
cp-scheduler-slack-metrics
************************************************************/
resource "aws_iam_role" "cp_scheduler_slack_metrics" {
  name = "cp-scheduler-slack-metrics-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_scheduler_slack_metrics" {
  for_each = {
    ecs_run_task          = aws_iam_policy.ecs_run_task.arn
    pass_role_to_ecs_task = aws_iam_policy.cp_scheduler_slack_metrics_pass_role_ecs.arn
    invoke_batch_lambda   = aws_iam_policy.scheduler_invoke_slack_metrics_batch_lambda.arn
  }

  role       = aws_iam_role.cp_scheduler_slack_metrics.name
  policy_arn = each.value
}

/************************************************************
cp-scheduler-cost-cutter
************************************************************/
resource "aws_iam_role" "cp_scheduler_cost_cutter" {
  name = "cp-scheduler-cost-cutter-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_scheduler_cost_cutter" {
  for_each = {
    ecs = aws_iam_policy.cp_scheduler_cost_cutter_ecs_write.arn
    rds = aws_iam_policy.rds_start_stop.arn
    ec2 = aws_iam_policy.ec2_start_stop.arn
  }

  role       = aws_iam_role.cp_scheduler_cost_cutter.name
  policy_arn = each.value
}

/************************************************************
administrator
************************************************************/
resource "aws_iam_role" "administrator" {
  name = "administrator-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::043309350350:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "administrator" {
  for_each = {
    administrator = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  role       = aws_iam_role.administrator.name
  policy_arn = each.value
}

/************************************************************
github-actions-oidc
************************************************************/
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

resource "aws_iam_role" "github_actions_oidc" {
  name = "github-actions-oidc-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:itaru-tok/cloud-pratica-backend-fork:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_oidc" {
  for_each = {
    github_actions = aws_iam_policy.github_actions.arn
  }

  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = each.value
}

/************************************************************
Step Functions 学習用（ステートマシン実行ロール）
************************************************************/
resource "aws_iam_role" "step_functions_practice" {
  name = "step-functions-practice-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_functions_practice_invoke_lambda" {
  role       = aws_iam_role.step_functions_practice.name
  policy_arn = aws_iam_policy.step_functions_practice_invoke_practice_lambda_calculate.arn
}

resource "aws_iam_role_policy_attachment" "step_functions_practice_ecs_write" {
  role       = aws_iam_role.step_functions_practice.name
  policy_arn = aws_iam_policy.step_functions_practice_ecs_write.arn
}

resource "aws_iam_role_policy_attachment" "step_functions_practice_pass_role_to_ecs_task" {
  role       = aws_iam_role.step_functions_practice.name
  policy_arn = aws_iam_policy.step_functions_practice_pass_role_to_ecs_task.arn
}

/************************************************************
media-compressor（Step Functions 実行ロール）
************************************************************/
resource "aws_iam_role" "step_functions_media_compressor" {
  name = "step-functions-media-compressor-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_functions_media_compressor_invoke_lambda" {
  role       = aws_iam_role.step_functions_media_compressor.name
  policy_arn = aws_iam_policy.step_functions_media_compressor_invoke_lambda.arn
}

resource "aws_iam_role_policy_attachment" "step_functions_media_compressor_ecs_write" {
  role       = aws_iam_role.step_functions_media_compressor.name
  policy_arn = aws_iam_policy.step_functions_media_compressor_ecs_write.arn
}

resource "aws_iam_role_policy_attachment" "step_functions_media_compressor_pass_role_to_ecs_task" {
  role       = aws_iam_role.step_functions_media_compressor.name
  policy_arn = aws_iam_policy.step_functions_media_compressor_pass_role_to_ecs_task.arn
}

/************************************************************
practice-lambda-calculate（Step Functions 学習用 Calculate Lambda）
************************************************************/
resource "aws_iam_role" "practice_lambda_calculate" {
  name = "practice-lambda-calculate-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "practice_lambda_calculate" {
  for_each = {
    cloudwatch = aws_iam_policy.cloud_watch_logs_write.arn
  }

  role       = aws_iam_role.practice_lambda_calculate.name
  policy_arn = each.value
}

/************************************************************
media-compressor-compress-image（Lambda）
************************************************************/
resource "aws_iam_role" "media_compressor_compress_image" {
  name = "media-compressor-compress-image-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "media_compressor_compress_image" {
  for_each = {
    cloudwatch = aws_iam_policy.cloud_watch_logs_write.arn
    s3         = aws_iam_policy.media_compressor_compress_image_s3.arn
  }

  role       = aws_iam_role.media_compressor_compress_image.name
  policy_arn = each.value
}

/************************************************************
media-compressor-compress-video（ECS タスクロール）
************************************************************/
resource "aws_iam_role" "media_compressor_compress_video" {
  name = "media-compressor-compress-video-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "media_compressor_compress_video" {
  for_each = {
    cloudwatch       = aws_iam_policy.cloud_watch_logs_write.arn
    s3               = aws_iam_policy.media_compressor_compress_video_s3.arn
    step_fn_callback = aws_iam_policy.media_compressor_compress_video_step_functions_callback.arn
  }

  role       = aws_iam_role.media_compressor_compress_video.name
  policy_arn = each.value
}

/************************************************************
media-compressor-notify-result（Lambda）
************************************************************/
resource "aws_iam_role" "media_compressor_notify_result" {
  name = "media-compressor-notify-result-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "media_compressor_notify_result" {
  for_each = {
    cloudwatch = aws_iam_policy.cloud_watch_logs_write.arn
  }

  role       = aws_iam_role.media_compressor_notify_result.name
  policy_arn = each.value
}

/************************************************************
practice-ecs-calculate（Step Functions 学習用 Calculate ECS タスクロール）
************************************************************/
resource "aws_iam_role" "practice_ecs_calculate" {
  name = "practice-ecs-calculate-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "practice_ecs_calculate" {
  for_each = {
    cloudwatch       = aws_iam_policy.cloud_watch_logs_write.arn
    step_fn_callback = aws_iam_policy.practice_ecs_calculate_step_functions_callback.arn
  }

  role       = aws_iam_role.practice_ecs_calculate.name
  policy_arn = each.value
}
