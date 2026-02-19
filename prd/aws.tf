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

# TODO: ALBのSGのinbound ruleをTerraformで管理
module "alb" {
  source                   = "../modules/aws/alb"
  env                      = local.env
  base_host                = local.base_host
  vpc_id                   = module.vpc.id
  public_subnet_ids        = module.subnet.public_subnet_ids
  certificate_arn          = module.acm_itaru_uk_ap_northeast_1.arn
  tg_slack_metrics_api_arn = module.target_group.arn_slack_metrics_api
  sg_alb_id                = module.security_group.id_alb
}

module "s3" {
  source = "../modules/aws/s3"
  env    = local.env
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
  source     = "../modules/aws/iam_role"
  env        = local.env
  region     = local.region
  account_id = local.account_id
}

module "ec2" {
  env              = local.env
  source           = "../modules/aws/ec2"
  public_subnet_id = module.subnet.id_public_subnet_1a
  bastion = {
    ami_id               = "ami-0d48053661ff2089b" // stg環境で構築した踏み台サーバのAMI ID
    iam_instance_profile = module.iam_role.instance_profile_cp_bastion
    security_group_id    = module.security_group.id_bastion
  }
  nat_1a = {
    # TODO: NATのインバウンドルールを2つ加える（マイグレーション実行時にコンソールから直接設定済み）
    ami_id               = "ami-063fed300ac346a89" // stg環境で構築したNATサーバのAMI ID
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
  // cloud-pratica-backendクラスター
  slack_metrics_api = {
    name                   = "slack-metrics-api-${local.env}"
    task_definition        = module.ecs_task_definition.arn_slack_metrics_api
    enable_execute_command = true
    capacity_provider      = "FARGATE_SPOT"
    target_group_arn       = module.target_group.arn_slack_metrics_api
    security_group_ids     = [module.security_group.id_slack_metrics_backend]
    subnet_ids             = module.subnet.private_subnet_ids
  }
}

module "ecs_task_definition" {
  source = "../modules/aws/ecs_task_definition"

  env = local.env

  ecr_url_slack_metrics = "${module.ecr.url_slack_metrics}:361434e" # CI/CD update target
  ecr_url_db_migrator   = "${module.ecr.url_db_migrator}:361434e"   # CI/CD update target

  ecs_task_execution_role_arn     = module.iam_role.role_arn_ecs_task_execution
  ecs_task_role_arn_slack_metrics = module.iam_role.role_arn_cp_slack_metrics_backend
  ecs_task_role_arn_db_migrator   = module.iam_role.role_arn_cp_db_migrator

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
  }
}

module "event_bridge_scheduler" {
  source = "../modules/aws/event_bridge_scheduler"

  env = local.env

  private_subnet_ids = module.subnet.private_subnet_ids

  slack_metrics = {
    iam_role_arn                             = module.iam_role.role_arn_cp_scheduler_slack_metrics
    ecs_cluster_arn                          = module.ecs.ecs_cluster_arn_cloud_pratica_backend
    ecs_task_definition_arn_without_revision = module.ecs_task_definition.arn_without_revision_slack_metrics_api
    security_group_id                        = module.security_group.id_slack_metrics_backend
  }

  cost_cutter = {
    enable                                = true
    iam_role_arn                          = module.iam_role.role_arn_cp_scheduler_cost_cutter
    ec2_instance_ids                      = [module.ec2.id_nat_1a, module.ec2.id_bastion]
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
      name   = module.acm_itaru_uk_ap_northeast_1.validation_record_name
      values = [module.acm_itaru_uk_us_east_1.validation_record_value]
      type   = "CNAME"
      ttl    = "300"
    },
  ]
  ses = {
    enable      = true
    dkim_tokens = module.ses.dkim_tokens
  }
}




