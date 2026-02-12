output "distribution_arn" {
  value = aws_cloudfront_distribution.slack_metrics.arn
}

output "distribution_id" {
  value = aws_cloudfront_distribution.slack_metrics.id
}

output "zone_id_us_east_1" {
  value = "Z2FDTNDATAQYW2"
}
