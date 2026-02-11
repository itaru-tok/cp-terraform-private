resource "aws_acm_certificate" "main" {
  provider          = aws
  domain_name       = var.domain_name
  validation_method = "DNS"
}
