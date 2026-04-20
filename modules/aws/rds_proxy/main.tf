resource "aws_db_proxy" "cloud_pratica" {
  name                   = var.db_proxy_name
  engine_family          = "POSTGRESQL"
  require_tls            = var.require_tls
  role_arn               = var.iam_role_arn_rds_proxy
  vpc_security_group_ids = [var.rds_proxy_security_group_id]
  vpc_subnet_ids         = var.vpc_subnet_ids

  auth {
    auth_scheme               = "SECRETS"
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    iam_auth                  = "REQUIRED"
    secret_arn                = var.secrets_manager_secret_arn
  }

  tags = {
    Name = var.db_proxy_name
  }
}

resource "aws_db_proxy_default_target_group" "cloud_pratica" {
  db_proxy_name = aws_db_proxy.cloud_pratica.name

  connection_pool_config {
    connection_borrow_timeout    = var.connection_borrow_timeout
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_db_proxy_target" "cloud_pratica" {
  db_proxy_name          = aws_db_proxy.cloud_pratica.name
  target_group_name      = "default"
  db_instance_identifier = var.db_instance_identifier
}
