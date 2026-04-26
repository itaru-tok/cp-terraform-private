/************************************************************
audit-log データベース（Glue Data Catalog）
Firehose が Parquet 変換時に参照する schema の保存先
************************************************************/
resource "aws_glue_catalog_database" "audit_log" {
  name = "audit_log_${var.env}"
}

/************************************************************
audit-log-slack-metrics Crawler
S3 の Parquet ファイルを読み取りスキーマを推定して
audit_log_{env} データベース配下に slack_metrics テーブルを維持する
************************************************************/
resource "aws_glue_crawler" "audit_log_slack_metrics" {
  name          = "audit-log-slack-metrics-${var.env}"
  role          = var.audit_log_slack_metrics.crawler_role_arn
  database_name = aws_glue_catalog_database.audit_log.name

  s3_target {
    path = "s3://${var.audit_log_slack_metrics.bucket_name}/parquet/slack_metrics"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_NEW_FOLDERS_ONLY"
  }

  schema_change_policy {
    update_behavior = "LOG"
    delete_behavior = "LOG"
  }

  lineage_configuration {
    crawler_lineage_settings = "DISABLE"
  }

  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Tables = {
        TableThreshold = 1
      }
    }
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
    CreatePartitionIndex = true
  })
}
