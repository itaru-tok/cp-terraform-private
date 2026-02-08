# AWS Import Templates (Terraform AWS Provider)

Use these as starting points and adjust to actual console values.
Always confirm the exact import ID format in the latest provider docs before finalizing.

## Root module wiring example (`stg/aws.tf`)

```hcl
module "vpc" {
  source = "../modules/aws/vpc"
  env    = local.env
}
```

## VPC

```hcl
# modules/aws/vpc/main.tf
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "cloud-pratica-${var.env}"
  }
}

import {
  to = module.vpc.aws_vpc.vpc
  id = "vpc-xxxxxxxxxxxxxxxxx"
}
```

## Subnet

```hcl
resource "aws_subnet" "public_1a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.0.0/18"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1a-${var.env}"
  }
}

import {
  to = module.subnet.aws_subnet.public_1a
  id = "subnet-xxxxxxxxxxxxxxxxx"
}
```

## Internet Gateway

```hcl
resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "cp-igw-${var.env}"
  }
}

import {
  to = module.igw.aws_internet_gateway.gw
  id = "igw-xxxxxxxxxxxxxxxxx"
}
```

## Route Table and Associations

```hcl
resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }
  tags = {
    Name = "cp-rtb-public-${var.env}"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = toset(var.public_subnet_ids)
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = each.value
}

import {
  to = module.rtb.aws_route_table.public_rt
  id = "rtb-xxxxxxxxxxxxxxxxx"
}

import {
  to = module.rtb.aws_route_table_association.public["subnet-xxxxxxxxxxxxxxxxx"]
  id = "subnet-xxxxxxxxxxxxxxxxx/rtb-xxxxxxxxxxxxxxxxx"
}
```

## Security Group

```hcl
resource "aws_security_group" "alb" {
  name        = "cp-alb-${var.env}"
  description = "Managed by Terraform"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-alb-${var.env}"
  }
}

import {
  to = module.security_group.aws_security_group.alb
  id = "sg-xxxxxxxxxxxxxxxxx"
}
```

## Security Group Rules (new split resources)

```hcl
resource "aws_vpc_security_group_ingress_rule" "db" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

import {
  to = module.security_group.aws_vpc_security_group_ingress_rule.db["bastion"]
  id = "sgr-xxxxxxxxxxxxxxxxx"
}
```

## ECR Repository and Lifecycle Policy

```hcl
resource "aws_ecr_repository" "main" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_lifecycle_policy" "retain_latest_images" {
  repository = aws_ecr_repository.main.name
  policy     = jsonencode({ rules = [] })
}

import {
  to = module.ecr.module.ecr_db_migrator.aws_ecr_repository.main
  id = "db-migrator-stg"
}

import {
  to = module.ecr.module.ecr_db_migrator.aws_ecr_lifecycle_policy.retain_latest_images
  id = "db-migrator-stg"
}
```

## Secrets Manager Secret

```hcl
resource "aws_secretsmanager_secret" "db_main_instance" {
  name = "db-main-instance-${var.env}"
}

import {
  to = module.secrets_manager.aws_secretsmanager_secret.db_main_instance
  id = "arn:aws:secretsmanager:ap-northeast-1:424848769759:secret:db-main-instance-stg-xxxxxx"
}
```

## SQS Queue and Queue Policy

```hcl
resource "aws_sqs_queue" "slack_metrics" {
  name = "slack-metrics-${var.env}"
}

resource "aws_sqs_queue_policy" "slack_metrics" {
  queue_url = aws_sqs_queue.slack_metrics.url
  policy    = jsonencode({ Version = "2012-10-17", Statement = [] })
}

import {
  to = module.sqs.aws_sqs_queue.slack_metrics
  id = "https://sqs.ap-northeast-1.amazonaws.com/424848769759/slack-metrics-stg"
}

import {
  to = module.sqs.aws_sqs_queue_policy.slack_metrics
  id = "https://sqs.ap-northeast-1.amazonaws.com/424848769759/slack-metrics-stg"
}
```

## Plan-stable fields checklist

Prefer including these fields early to reduce diff/noise:

- networking: `tags`, route targets (`gateway_id`, `network_interface_id`)
- security group: explicit `description`, rule split resources, protocol/ports
- ecr: `image_tag_mutability`, lifecycle policy JSON
- sqs: `visibility_timeout_seconds`, `message_retention_seconds`, `redrive_policy`
- secret: stable `name`
