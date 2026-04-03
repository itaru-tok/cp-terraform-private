data "aws_eks_cluster" "cloud_pratica" {
  name = "cloud-pratica-${var.env}"
}
