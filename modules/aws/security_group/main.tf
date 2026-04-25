resource "aws_security_group" "alb" {
  name        = "cp-alb-${var.env}"
  description = "Managed by Terraform"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-alb-${var.env}"
  }
}

resource "aws_security_group" "bastion" {
  name        = "cp-bastion-${var.env}"
  description = "ec2 bastion server sg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-bastion-${var.env}"
  }
}

resource "aws_security_group" "nat" {
  name        = "cp-nat-${var.env}"
  description = "nat stg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-nat-${var.env}"
  }
}

resource "aws_security_group" "slack_metrics_backend" {
  name        = "cp-slack-metrics-backend-${var.env}"
  description = "Managed by Terraform"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-slack-metrics-backend-${var.env}"
  }
}

resource "aws_security_group" "db_migrator" {
  name        = "cp-db-migrator-${var.env}"
  description = "db migrator ecs sg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-db-migrator-${var.env}"
  }
}

resource "aws_security_group" "db" {
  name        = "cp-db-${var.env}"
  description = "RDS security group"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-db-${var.env}"
  }
}

resource "aws_security_group" "slack_metrics_lambda" {
  name        = "cp-slack-metrics-lambda-${var.env}"
  description = "slack-metrics Lambda (VPC)"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-slack-metrics-lambda-${var.env}"
  }
}

resource "aws_security_group" "media_compressor_compress_video" {
  name        = "cp-media-compressor-compress-video-${var.env}"
  description = "media-compressor compress-video ecs task sg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-media-compressor-compress-video-${var.env}"
  }
}

resource "aws_security_group" "batch" {
  name        = "cp-batch-${var.env}"
  description = "default sg for AWS Batch compute environments"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-batch-${var.env}"
  }
}

# Interface 型 VPC エンドポイントの ENI にアタッチする共通 SG。
# 全 Interface エンドポイントで使い回す運用にする。
resource "aws_security_group" "vpc_endpoint" {
  name        = "cp-vpc-endpoint-${var.env}"
  description = "shared sg for interface type VPC endpoints"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cp-vpc-endpoint-${var.env}"
  }
}

# --- Inbound Rules ---

# TODO: NATのインバウンドルールを2つ加える（マイグレーション実行時にstg/prdのコンソールから直接設定済み）

resource "aws_vpc_security_group_ingress_rule" "db" {
  for_each = {
    bastion               = aws_security_group.bastion.id
    slack_metrics_backend = aws_security_group.slack_metrics_backend.id
    db_migrator           = aws_security_group.db_migrator.id
    slack_metrics_lambda  = aws_security_group.slack_metrics_lambda.id
    batch                 = aws_security_group.batch.id
  }

  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = each.value
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "slack_metrics_backend" {
  security_group_id            = aws_security_group.slack_metrics_backend.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# 最小権限: サブネット CIDR ではなく、VPC エンドポイントを呼び出すリソース
# の SG だけを許可する。今は Lambda だけだが、利用元が増えたら for_each に追加。
resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint" {
  for_each = {
    slack_metrics_lambda = aws_security_group.slack_metrics_lambda.id
  }

  security_group_id            = aws_security_group.vpc_endpoint.id
  referenced_security_group_id = each.value
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

# --- Outbound Rules ---

resource "aws_vpc_security_group_egress_rule" "alb" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.slack_metrics_backend.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "nat" {
  security_group_id = aws_security_group.nat.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "slack_metrics_backend" {
  security_group_id = aws_security_group.slack_metrics_backend.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "db_migrator" {
  security_group_id = aws_security_group.db_migrator.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "db" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "slack_metrics_lambda" {
  security_group_id = aws_security_group.slack_metrics_lambda.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "media_compressor_compress_video" {
  security_group_id = aws_security_group.media_compressor_compress_video.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "batch" {
  security_group_id = aws_security_group.batch.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "vpc_endpoint" {
  security_group_id = aws_security_group.vpc_endpoint.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
