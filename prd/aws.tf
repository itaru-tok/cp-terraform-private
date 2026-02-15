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
  network_interface_id = null
}

module "security_group" {
  source = "../modules/aws/security_group"
  env    = local.env
  vpc_id = module.vpc.id
}

module "route53_itaru_uk" {
  source    = "../modules/aws/route53_unit"
  zone_name = local.base_host
  records   = []
}

module "iam_role" {
  source     = "../modules/aws/iam_role"
  env        = local.env
  region     = local.region
  account_id = local.account_id
}

module "s3" {
  source = "../modules/aws/s3"
  env    = local.env
}
