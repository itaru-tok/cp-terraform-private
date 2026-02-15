output "arn" {
  value = aws_acm_certificate.main.arn
}

output "domain_validation_options" {
  value = aws_acm_certificate.main.domain_validation_options
}

output "validation_record_name" {
  value = tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_name
}

output "validation_record_value" {
  value = tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_value
}
