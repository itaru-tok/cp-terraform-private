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

import {
  to = module.security_group.aws_security_group.alb
  id = "sg-08990834ac94c4873"
}

import {
  to = module.security_group.aws_security_group.bastion
  id = "sg-04ab2345c6a7840ea"
}

import {
  to = module.security_group.aws_security_group.nat
  id = "sg-050f0505ebbc70dac"
}

import {
  to = module.security_group.aws_security_group.slack_metrics_backend
  id = "sg-037caa6a559e00063"
}

import {
  to = module.security_group.aws_security_group.db_migrator
  id = "sg-0e5231ce88f2fe9c1"
}

import {
  to = module.security_group.aws_security_group.db
  id = "sg-09eb04f1f5b14ffbc"
}

# Inbound Rules for DB
import {
  to = module.security_group.aws_vpc_security_group_ingress_rule.db["bastion"]
  id = "sgr-0dea9eddcebc19364"
}

import {
  to = module.security_group.aws_vpc_security_group_ingress_rule.db["slack_metrics_backend"]
  id = "sgr-0566bc8c8117eaa12"
}

import {
  to = module.security_group.aws_vpc_security_group_ingress_rule.db["db_migrator"]
  id = "sgr-0508f6d0b2223d3e0"
}

module "security_group" {
  source = "../modules/aws/security_group"
  env    = local.env
  vpc_id = module.vpc.id
}
