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
