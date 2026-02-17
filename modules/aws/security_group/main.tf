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

# --- Inbound Rules ---

# TODO: NATのインバウンドルールを2つ加える（マイグレーション実行時にstg/prdのコンソールから直接設定済み）

resource "aws_vpc_security_group_ingress_rule" "db" {
  for_each = {
    bastion               = aws_security_group.bastion.id
    slack_metrics_backend = aws_security_group.slack_metrics_backend.id
    db_migrator           = aws_security_group.db_migrator.id
  }

  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = each.value
  from_port                    = 5432
  to_port                      = 5432
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
