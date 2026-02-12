locals {
  // MEMO: AWSで設定されるグローバルな固定値
  cache_policy_id = {
    caching_optimized = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    caching_disabled  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  }
  // MEMO: AWSで設定されるグローバルな固定値
  origin_request_policy_id = {
    all_viewer_except_host_header = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
  }
}

resource "aws_cloudfront_origin_access_control" "s3_slack_metrics" {
  name                              = "s3-slack-metrics-${var.env}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "slack_metrics" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "slack-metrics-${var.env}"
  aliases         = var.aliases

  origin {
    domain_name = var.amplify_domain_name
    origin_id   = var.amplify_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name              = var.s3_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_slack_metrics.id
    origin_id                = var.s3_origin_id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.amplify_origin_id

    viewer_protocol_policy   = "https-only"
    cache_policy_id          = local.cache_policy_id.caching_disabled
    origin_request_policy_id = local.origin_request_policy_id.all_viewer_except_host_header
    compress                 = true
  }

  ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id

    viewer_protocol_policy = "https-only"
    cache_policy_id        = local.cache_policy_id.caching_optimized
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
