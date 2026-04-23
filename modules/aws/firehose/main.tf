/************************************************************
audit-log-slack-metrics
CloudWatch Logs サブスクリプション（DirectPut）→ Firehose
→ Lambda(firehose-cwlogs-transformer) で NDJSON 変換
→ Firehose が Glue スキーマを参照して Parquet に変換
→ S3（cp-audit-log-itaru）配下の parquet/ へ出力
************************************************************/
resource "aws_kinesis_firehose_delivery_stream" "audit_log_slack_metrics" {
  name        = "audit-log-slack-metrics-${var.env}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = var.audit_log_slack_metrics.role_arn
    bucket_arn          = var.audit_log_slack_metrics.bucket_arn
    prefix              = "parquet/slack_metrics/!{timestamp:'year='yyyy'/month='MM'/day='dd'/hour='HH}/"
    error_output_prefix = "error/"
    buffering_size      = 64
    buffering_interval  = 10
    compression_format  = "UNCOMPRESSED"
    file_extension      = ".parquet"
    custom_time_zone    = "Asia/Tokyo"

    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${var.audit_log_slack_metrics.transformer_lambda_arn}:$LATEST"
        }
        parameters {
          parameter_name  = "NumberOfRetries"
          parameter_value = "3"
        }
        parameters {
          parameter_name  = "RoleArn"
          parameter_value = var.audit_log_slack_metrics.role_arn
        }
        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = "1"
        }
        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = "10"
        }
      }
    }

    data_format_conversion_configuration {
      enabled = true

      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        role_arn      = var.audit_log_slack_metrics.role_arn
        database_name = var.audit_log_slack_metrics.glue_database_name
        table_name    = var.audit_log_slack_metrics.glue_table_name
        region        = var.audit_log_slack_metrics.glue_region
        version_id    = "LATEST"
      }
    }

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/audit-log-slack-metrics-${var.env}"
      log_stream_name = "DestinationDelivery"
    }
  }
}
