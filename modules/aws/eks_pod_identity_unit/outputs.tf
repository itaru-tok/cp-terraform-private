output "association_ids" {
  value = { for k, a in aws_eks_pod_identity_association.association : k => a.id }
}
