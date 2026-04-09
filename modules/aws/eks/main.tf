resource "aws_eks_cluster" "cloud_pratica" {
  name                          = "cloud-pratica-${var.env}"
  role_arn                      = var.cloud_pratica.cluster_role_arn
  bootstrap_self_managed_addons = false
  version                       = var.cloud_pratica.kubernetes_version

  upgrade_policy {
    support_type = "STANDARD"
  }

  access_config {
    bootstrap_cluster_creator_admin_permissions = true
    authentication_mode                         = "API"
  }

  zonal_shift_config {
    enabled = false
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    public_access_cidrs     = ["0.0.0.0/0"]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "172.20.0.0/16"
    elastic_load_balancing {
      enabled = false
    }
  }

  enabled_cluster_log_types = []
}

resource "aws_eks_node_group" "cloud_pratica" {
  cluster_name    = aws_eks_cluster.cloud_pratica.name
  node_group_name = "cp-app-${var.env}"
  node_role_arn   = var.cloud_pratica.node_role_arn

  subnet_ids = var.private_subnet_ids

  scaling_config {
    desired_size = var.cloud_pratica.node_desired_count
    min_size     = 0
    max_size     = var.cloud_pratica.node_desired_count
  }

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = var.cloud_pratica.node_capacity_type
  instance_types = [var.cloud_pratica.node_instance_type]

  disk_size = 20

  update_config {
    max_unavailable = 1
  }
}

data "aws_eks_cluster" "cloud_pratica" {
  name = aws_eks_cluster.cloud_pratica.name

  depends_on = [
    aws_eks_cluster.cloud_pratica,
  ]
}
