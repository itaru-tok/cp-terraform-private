resource "aws_eks_pod_identity_association" "association" {
  for_each        = { for assoc in var.associations : assoc.service_account => assoc }
  cluster_name    = var.cluster_name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = each.value.role_arn
}
