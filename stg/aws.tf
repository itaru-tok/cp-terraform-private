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
  public_subnet_ids    = local.public_subnet_ids
  private_subnet_ids   = local.private_subnet_ids
  network_interface_id = "eni-0d422ebf54d57088b"
}

module "security_group" {
  source = "../modules/aws/security_group"
  env    = local.env
  vpc_id = module.vpc.id
}

module "ecr" {
  source = "../modules/aws/ecr"
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
  domain                 = local.ses_domain
  mail_from_domain       = local.ses_mail_from_domain
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"
}

module "iam_role" {
  source = "../modules/aws/iam_role"
  env    = local.env
}

module "ec2" {
  source              = "../modules/aws/ec2"
  env                 = local.env
  public_subnet_1a_id = module.subnet.id_public_subnet_1a
  sg_bastion_id       = module.security_group.id_bastion
  sg_nat_id           = module.security_group.id_nat
}
