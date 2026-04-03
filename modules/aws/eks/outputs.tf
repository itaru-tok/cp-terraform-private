output "cp_cluster_security_group_id" {
  value = data.aws_eks_cluster.cloud_pratica.vpc_config[0].cluster_security_group_id
}
