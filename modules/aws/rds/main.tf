resource "random_password" "db" {
  length  = 16
  special = false
}

resource "aws_db_subnet_group" "subnet_group" {
  name = "cp-db-subnet-group-${var.env}"
  subnet_ids = [
    var.private_subnet_1a_id,
    var.private_subnet_1c_id,
  ]
}

resource "aws_db_parameter_group" "parameter_group" {
  name   = "cp-db-parameter-group-${var.env}"
  family = "postgres16"
}

resource "aws_db_instance" "main" {
  identifier                   = "cloud-pratica-${var.env}"
  engine                       = "postgres"
  engine_version               = "16.9"
  instance_class               = "db.t3.micro"
  allocated_storage            = 20
  storage_type                 = "gp3"
  storage_encrypted            = true
  username                     = "postgres"
  db_name                      = "slack_metrics"
  password                     = random_password.db.result
  db_subnet_group_name         = aws_db_subnet_group.subnet_group.name
  parameter_group_name         = "default.postgres16"
  vpc_security_group_ids       = [var.db_security_group_id]
  port                         = 5432
  publicly_accessible          = false
  multi_az                     = false
  copy_tags_to_snapshot        = true
  performance_insights_enabled = false
  skip_final_snapshot          = true

  lifecycle {
    ignore_changes = [password]
  }
}
