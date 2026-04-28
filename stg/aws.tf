module "vpc" {
  source = "../modules/aws/vpc"
  env    = local.env
}

module "subnet" {
  source = "../modules/aws/subnet"
  env    = local.env
  vpc_id = module.vpc.id
}

module "igw" {
  source = "../modules/aws/internet_gateway"
  env    = local.env
  vpc_id = module.vpc.id
}

module "rtb" {
  source               = "../modules/aws/route_table"
  env                  = local.env
  vpc_id               = module.vpc.id
  gateway_id           = module.igw.id
  public_subnet_ids    = module.subnet.public_subnet_ids
  private_subnet_ids   = module.subnet.private_subnet_ids
  network_interface_id = module.ec2.network_interface_id_nat_1a
}

module "security_group" {
  source = "../modules/aws/security_group"
  env    = local.env
  vpc_id = module.vpc.id
}

module "target_group" {
  source = "../modules/aws/target_group"
  env    = local.env
  vpc_id = module.vpc.id
}

module "ecr" {
  source = "../modules/aws/ecr"
  env    = local.env
}

module "alb" {
  source                   = "../modules/aws/alb"
  env                      = local.env
  base_host                = local.base_host
  vpc_id                   = module.vpc.id
  public_subnet_ids        = module.subnet.public_subnet_ids
  certificate_arn          = module.acm_itaru_uk_ap_northeast_1.arn
  tg_slack_metrics_api_arn = module.target_group.arn_slack_metrics_api
  sg_alb_id                = module.security_group.id_alb
  tg_cost_api_arn          = module.target_group.arn_cost_api
  cost_api_host            = "cost-api.${local.base_host}"
}

module "s3" {
  source = "../modules/aws/s3"
  env    = local.env
  slack_metrics = {
    cloudfront_distribution_arn = module.cloudfront.distribution_arn
  }
  media_compressor = {
    enabled = true
  }
}

module "cloudfront" {
  source                            = "../modules/aws/cloudfront"
  env                               = local.env
  certificate_arn                   = module.acm_itaru_uk_us_east_1.arn
  amplify_domain_name_slack_metrics = local.amplify_domain_name_slack_metrics
  aliases                           = ["sm.${local.base_host}"]
}

module "secrets_manager" {
  source = "../modules/aws/secrets_manager"
  env    = local.env
}

module "sqs" {
  source     = "../modules/aws/sqs"
  env        = local.env
  account_id = local.account_id
}

module "ses" {
  source                 = "../modules/aws/ses"
  env                    = local.env
  domain                 = local.base_host
  mail_from_domain       = local.ses_mail_from_domain
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"
}

module "iam_role" {
  source                             = "../modules/aws/iam_role"
  env                                = local.env
  region                             = local.region
  account_id                         = local.account_id
  media_compressor_bucket_arn        = module.s3.s3_bucket_arn_media_compressor
  media_compressor_state_machine_arn = local.media_compressor_state_machine_arn
  audit_log_bucket_arn               = module.s3.s3_bucket_arn_audit_log
  datadog_external_id                = module.datadog_aws_integration.external_id
  datadog_permission_chunks          = module.datadog_aws_integration.permission_chunks
}

# MEMO: コスト削減のため
# module "eks" {
#   source             = "../modules/aws/eks"
#   env                = local.env
#   private_subnet_ids = module.subnet.private_subnet_ids
#   cloud_pratica = {
#     cluster_role_arn     = module.iam_role.role_arn_cp_k8s_cluster
#     node_role_arn        = module.iam_role.role_arn_cp_k8s_node
#     node_instance_type   = "t3.large"
#     node_capacity_type   = "SPOT"
#     node_desired_count   = 1
#     kubernetes_version   = local.eks_kubernetes_version
#   }
# }

# EKS クラスター SG → RDS（cp-db）: モジュール外で定義すると Terraform LS が「想定外の属性」と誤検知しない
# MEMO: コスト削減のため
# resource "aws_vpc_security_group_ingress_rule" "db_from_eks_cluster" {
#   security_group_id            = module.security_group.id_db
#   referenced_security_group_id = module.eks.cp_cluster_security_group_id
#   from_port                    = 5432
#   to_port                      = 5432
#   ip_protocol                  = "tcp"
# }

# MEMO: コスト削減のため
# module "eks_pod_identity" {
#   source         = "../modules/aws/eks_pod_identity_unit"
#   cluster_name   = local.eks_cluster_name
#   associations = [
#     {
#       namespace       = "external-secrets"
#       service_account = "external-secrets-operator-sa"
#       role_arn        = module.iam_role.role_arn_cp_k8s_eso
#     },
#     {
#       namespace       = "app"
#       service_account = "db-migrator-sa"
#       role_arn        = module.iam_role.role_arn_cp_db_migrator
#     },
#     {
#       namespace       = "app"
#       service_account = "slack-metrics-sa"
#       role_arn        = module.iam_role.role_arn_cp_slack_metrics_backend
#     },
#     {
#       namespace       = "kube-system"
#       service_account = "alb-controller-sa"
#       role_arn        = module.iam_role.role_arn_cp_k8s_alb_controller
#     },
#     {
#       namespace       = "kube-system"
#       service_account = "ebs-csi-controller-sa"
#       role_arn        = module.iam_role.role_arn_cp_k8s_ebs_csi_driver
#     },
#     {
#       namespace       = "kube-system"
#       service_account = "ebs-csi-driver-sa"
#       role_arn        = module.iam_role.role_arn_cp_k8s_ebs_csi_driver
#     },
#     {
#       namespace       = "argocd"
#       service_account = "argocd-image-updater-sa"
#       role_arn        = module.iam_role.role_arn_cp_argocd_image_updater
#     },
#     {
#       namespace       = "monitoring"
#       service_account = "log-transfer-sa"
#       role_arn        = module.iam_role.role_arn_cp_k8s_log_transfer
#     },
#   ]
#
#   depends_on = [module.eks]
# }

module "ec2" {
  source           = "../modules/aws/ec2"
  env              = local.env
  public_subnet_id = module.subnet.id_public_subnet_1a
  bastion = {
    ami_id               = "ami-0d48053661ff2089b"
    iam_instance_profile = module.iam_role.instance_profile_cp_bastion
    security_group_id    = module.security_group.id_bastion
  }
  nat_1a = {
    # TODO: NATのインバウンドルールを2つ加える（マイグレーション実行時にコンソールから直接設定済み）
    ami_id               = "ami-063fed300ac346a89"
    iam_instance_profile = module.iam_role.instance_profile_cp_nat
    security_group_id    = module.security_group.id_nat
  }
}

module "rds" {
  source               = "../modules/aws/rds"
  env                  = local.env
  private_subnet_1a_id = module.subnet.id_private_subnet_1a
  private_subnet_1c_id = module.subnet.id_private_subnet_1c
  db_security_group_id = module.security_group.id_db
}

module "ecs" {
  source = "../modules/aws/ecs"
  env    = local.env

  slack_metrics_api = {
    name                   = "slack-metrics-api-${local.env}"
    task_definition        = module.ecs_task_definition.arn_slack_metrics_api
    enable_execute_command = true
    capacity_provider      = "FARGATE_SPOT"
    target_group_arn       = module.target_group.arn_slack_metrics_api
    security_group_ids     = [module.security_group.id_slack_metrics_backend]
    subnet_ids             = module.subnet.private_subnet_ids
  }

  cost_api = {
    name                   = "cost-api-${local.env}"
    task_definition        = "cost-api-${local.env}"
    enable_execute_command = true
    capacity_provider      = "FARGATE_SPOT"
    target_group_arn       = module.target_group.arn_cost_api
    security_group_ids     = [module.security_group.id_cost_api]
    subnet_ids             = module.subnet.private_subnet_ids
  }
}

module "ecs_task_definition" {
  source = "../modules/aws/ecs_task_definition"

  env = local.env

  ecr_url_slack_metrics                   = "${module.ecr.url_slack_metrics}:0d0d629" # CI/CD update target
  ecr_url_db_migrator                     = "${module.ecr.url_db_migrator}:c5291c1"   # CI/CD update target
  ecr_url_media_compressor_compress_video = "${module.ecr.url_media_compressor_compress_video}:${local.media_compressor_compress_video_image_tag}"

  ecs_task_execution_role_arn                       = module.iam_role.role_arn_ecs_task_execution
  ecs_task_role_arn_slack_metrics                   = module.iam_role.role_arn_cp_slack_metrics_backend
  ecs_task_role_arn_db_migrator                     = module.iam_role.role_arn_cp_db_migrator
  ecs_task_role_arn_media_compressor_compress_video = module.iam_role.role_arn_media_compressor_compress_video

  secrets_manager_arn_db_main_instance = module.secrets_manager.arn_db_main_instance
  arn_cp_config_bucket                 = module.s3.s3_bucket_arn_cp_config

  ecs_task_specs = {
    slack_metrics_api = {
      cpu    = 256
      memory = 512
    }
    slack_metrics_batch = {
      cpu    = 256
      memory = 512
    }
    db_migrator = {
      cpu    = 256
      memory = 512
    }
    media_compressor_compress_video = {
      cpu    = 2048
      memory = 4096
    }
  }
}

module "lambda" {
  source             = "../modules/aws/lambda"
  env                = local.env
  aws_account_id     = local.account_id
  region             = local.region
  private_subnet_ids = module.subnet.private_subnet_ids

  slack_metrics = {
    role_arn          = module.iam_role.role_arn_cp_slack_metrics_lambda
    image_uri         = "${module.ecr.url_slack_metrics_lambda}:${local.slack_metrics_lambda_image_tag}"
    security_group_id = module.security_group.id_slack_metrics_lambda
    sqs_arn           = module.sqs.arn_slack_metrics
  }

  practice_lambda_calculate = {
    role_arn  = module.iam_role.role_arn_practice_lambda_calculate
    image_uri = "${module.ecr.url_practice_lambda_calculate}:${local.practice_lambda_calculate_image_tag}"
  }

  media_compressor_compress_image = {
    role_arn  = module.iam_role.role_arn_media_compressor_compress_image
    image_uri = "${module.ecr.url_media_compressor_compress_image}:${local.media_compressor_compress_image_image_tag}"
  }

  media_compressor_notify_result = {
    role_arn        = module.iam_role.role_arn_media_compressor_notify_result
    image_uri       = "${module.ecr.url_media_compressor_notify_result}:${local.media_compressor_notify_result_image_tag}"
    slack_bot_token = module.ssm_parameter.slack_bot_token
  }

  media_compressor_invoker = {
    role_arn          = module.iam_role.role_arn_media_compressor_invoker
    image_uri         = "${module.ecr.url_media_compressor_invoker}:${local.media_compressor_invoker_image_tag}"
    state_machine_arn = local.media_compressor_state_machine_arn
  }

  firehose_cwlogs_transformer = {
    role_arn  = module.iam_role.role_arn_firehose_cwlogs_transformer
    image_uri = "${module.ecr.url_firehose_cwlogs_transformer}:${local.firehose_cwlogs_transformer_image_tag}"
  }
}

module "glue" {
  source = "../modules/aws/glue"
  env    = local.env

  audit_log_slack_metrics = {
    crawler_role_arn = module.iam_role.role_arn_glue_crawler_audit_log
    bucket_name      = module.s3.s3_bucket_id_audit_log
  }
}

module "athena" {
  source = "../modules/aws/athena"
  env    = local.env

  primary = {
    query_result_bucket_id = module.s3.s3_bucket_id_athena_query_result
  }
}

module "firehose" {
  source = "../modules/aws/firehose"
  env    = local.env

  audit_log_slack_metrics = {
    role_arn               = module.iam_role.role_arn_cp_audit_log_firehose
    bucket_arn             = module.s3.s3_bucket_arn_audit_log
    transformer_lambda_arn = module.lambda.arn_firehose_cwlogs_transformer
    glue_database_name     = module.glue.audit_log_database_name
    glue_table_name        = "slack_metrics"
    glue_region            = local.region
  }
}

module "cloudwatch_log_group" {
  source = "../modules/aws/cloudwatch_log_group"
  env    = local.env

  audit_log_slack_metrics = {
    firehose_arn                 = module.firehose.arn_audit_log_slack_metrics
    subscription_filter_role_arn = module.iam_role.role_arn_logs_lambda_slack_metrics_api
  }
}

module "sns" {
  source = "../modules/aws/sns"
  env    = local.env
}

module "cloudwatch_alarm" {
  source = "../modules/aws/cloudwatch_alarm"
  env    = local.env

  ntf_alarm_sns_topic_arn = module.sns.arn_ntf_alarm

  server_error_slack_metrics_api = {
    alarm_description = "【いたる】\nSlack Metrics APIで1分間に10回以上のサーバエラーが発生しました。\n直ちに以下のロググループを確認してください！\n\n```\n/aws/lambda/slack-metrics-api-${local.env}\n```"
  }

  rds_cpu_cloud_pratica = {
    alarm_description = "【いたる】\nRDS Cloud Practical StagingインスタンスのCPU使用率が 閾値の70%を超えました。直ちにスペックの調整を行ってください。"
  }
}

module "amazon_q_chat" {
  source = "../modules/aws/amazon_q_chat"
  env    = local.env

  ntf_alarm = {
    iam_role_arn     = module.iam_role.role_arn_cp_q_developer
    sns_topic_arn    = module.sns.arn_ntf_alarm
    slack_team_id    = "T088SK8B43U"
    slack_channel_id = "C09C4R1RAUQ"
  }
}

# TEMP-IMPORT-DISABLED-START: import 中だけ count 評価を止めるためコメントアウト。import 完了後に必ず戻す
/*
# TEMP-IMPORT-DISABLED-START: import 中だけ count 評価を止めるためコメントアウト。import 完了後に必ず戻す
/*
resource "aws_lambda_permission" "media_compressor_s3_invoke_invoker" {
  count = module.s3.s3_bucket_id_media_compressor != null ? 1 : 0

  statement_id  = "AllowExecutionFromS3MediaCompressor"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name_media_compressor_invoker
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3.s3_bucket_arn_media_compressor
}

resource "aws_s3_bucket_notification" "media_compressor_invoker" {
  count = module.s3.s3_bucket_id_media_compressor != null ? 1 : 0

  bucket = module.s3.s3_bucket_id_media_compressor

  lambda_function {
    lambda_function_arn = module.lambda.arn_media_compressor_invoker
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/workspaces/1/"
  }

  depends_on = [aws_lambda_permission.media_compressor_s3_invoke_invoker]
}
*/
# TEMP-IMPORT-DISABLED-END

module "batch" {
  source             = "../modules/aws/batch"
  env                = local.env
  region             = local.region
  account_id         = local.account_id
  private_subnet_ids = module.subnet.private_subnet_ids

  slack_metrics = {
    security_group_id = module.security_group.id_batch
  }
}

module "event_bridge_scheduler" {
  source             = "../modules/aws/event_bridge_scheduler"
  env                = local.env
  private_subnet_ids = [module.subnet.id_private_subnet_1a]

  slack_metrics = {
    iam_role_arn                             = module.iam_role.role_arn_cp_scheduler_slack_metrics
    ecs_cluster_arn                          = module.ecs.ecs_cluster_arn_cloud_pratica_backend
    ecs_task_definition_arn_without_revision = module.ecs_task_definition.arn_without_revision_slack_metrics_batch
    security_group_id                        = module.security_group.id_slack_metrics_backend
  }

  slack_metrics_v3 = {
    lambda_arn = module.lambda.arn_slack_metrics_batch
  }

  slack_metrics_v2 = {
    job_queue_arn      = module.batch.job_queue_arn_slack_metrics
    job_definition_arn = module.batch.job_definition_arn_slack_metrics
  }

  cost_cutter = {
    # MEMO: コスト削減のため（EC2 モジュール停止時はスケジュール無効・対象なし）
    enable                                = false
    iam_role_arn                          = module.iam_role.role_arn_cp_scheduler_cost_cutter
    ec2_instance_ids                      = []
    ecs_cluster_arn_cloud_pratica_backend = module.ecs.ecs_cluster_arn_cloud_pratica_backend
  }
}

module "acm_itaru_uk_ap_northeast_1" {
  source      = "../modules/aws/acm_unit"
  domain_name = "*.${local.base_host}"
  providers = {
    aws = aws
  }
}

module "acm_itaru_uk_us_east_1" {
  source      = "../modules/aws/acm_unit"
  domain_name = "*.${local.base_host}"
  providers = {
    aws = aws.us_east_1
  }
}

# EKS Ingress（ALB Controller）が作成する共有 ALB — sm-api-v2 はここを向ける
# MEMO: コスト削減のため（EKS 停止時はコメントアウト。復旧後に sm-api-v2 レコードも戻す）
# data "aws_lb" "k8s_shared" {
#   tags = {
#     "elbv2.k8s.aws/cluster" = local.eks_cluster_name
#   }
# }

module "route53_itaru_uk" {
  source    = "../modules/aws/route53_unit"
  zone_name = local.base_host

  records = [
    {
      name = "sm-api.${local.base_host}"
      type = "A"
      alias = {
        name                   = module.alb.dns_name
        zone_id                = module.alb.zone_id_ap_northeast_1
        evaluate_target_health = true
      }
    },
    {
      name = "cost-api.${local.base_host}"
      type = "A"
      alias = {
        name                   = module.alb.dns_name
        zone_id                = module.alb.zone_id_ap_northeast_1
        evaluate_target_health = true
      }
    },
    # MEMO: コスト削減のため（data.aws_lb.k8s_shared 停止に合わせてコメントアウト）
    # {
    #   name = "sm-api-v2.${local.base_host}"
    #   type = "A"
    #   alias = {
    #     name                   = data.aws_lb.k8s_shared.dns_name
    #     zone_id                = data.aws_lb.k8s_shared.zone_id
    #     evaluate_target_health = true
    #   }
    # },
    {
      name = "sm.${local.base_host}"
      type = "A"
      alias = {
        name                   = "${module.cloudfront.domain_name}."
        zone_id                = module.cloudfront.zone_id_us_east_1
        evaluate_target_health = false
      }
    },
    {
      name   = trimsuffix(tolist(module.acm_itaru_uk_ap_northeast_1.domain_validation_options)[0].resource_record_name, ".")
      type   = "CNAME"
      values = [tolist(module.acm_itaru_uk_ap_northeast_1.domain_validation_options)[0].resource_record_value]
      ttl    = 300
    }
  ]

  ses = {
    enable      = true
    dkim_tokens = module.ses.dkim_tokens
  }
}

module "ssm_parameter" {
  source                      = "../modules/aws/ssm_parameter"
  env                         = local.env
  image_tag_slack_metrics     = "0d0d629"
  image_tag_db_migrator       = "c5291c1"
  private_subnet_id_1a        = module.subnet.id_private_subnet_1a
  private_subnet_id_1c        = module.subnet.id_private_subnet_1c
  s3_arn_cp_config            = module.s3.s3_bucket_arn_cp_config
  aws_account_id              = local.account_id
  sg_id_slack_metrics_backend = module.security_group.id_slack_metrics_backend
  sg_id_db_migrator           = module.security_group.id_db_migrator
  tg_arn_slack_metrics_api    = module.target_group.arn_slack_metrics_api
}
