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

