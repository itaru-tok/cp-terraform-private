module "cp_config" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = "cp-itaru-config-${var.env}"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  # Public access block
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "audit_log" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = "cp-audit-log-itaru-${var.env}"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "cp_slack_metrics" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = "cp-slack-metrics-itaru-${var.env}"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  # Public access block
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Lifecycle rule
  lifecycle_rule = [
    {
      id      = "noncurrent-version-expiration"
      enabled = true

      noncurrent_version_expiration = {
        days = 90
      }
    }
  ]
}

resource "aws_s3_bucket_policy" "slack_metrics" {
  count  = var.slack_metrics.cloudfront_distribution_arn != null ? 1 : 0
  bucket = module.cp_slack_metrics.s3_bucket_id
  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::cp-slack-metrics-itaru-${var.env}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" : var.slack_metrics.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}

module "media_compressor" {
  count   = var.media_compressor.enabled ? 1 : 0
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = "cp-media-compressor-itaru-${var.env}"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Athena のクエリ結果を保存する専用バケット。
# 結果は一時的な利用が前提なので、30 日経過したオブジェクトはライフサイクルで自動削除する。
module "athena_query_result" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = "cp-athena-query-result-itaru-${var.env}"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle_rule = [
    {
      id      = "expire-query-results"
      enabled = true

      expiration = {
        days = 30
      }

      abort_incomplete_multipart_upload_days = 7
    }
  ]
}
