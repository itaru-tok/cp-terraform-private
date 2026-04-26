/************************************************************
primary ワークグループ
- クエリ結果は cp-athena-query-result-itaru-{env} バケットへ
- クエリあたりのスキャン上限 10 MB
- ワークグループ設定をクライアント設定より優先
- CloudWatch メトリクスを発行
- エンジンバージョンは AUTO（= 実効値 v3）
************************************************************/
resource "aws_athena_workgroup" "primary" {
  name  = "primary"
  state = "ENABLED"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    bytes_scanned_cutoff_per_query     = 10 * 1024 * 1024
    requester_pays_enabled             = false

    engine_version {
      selected_engine_version = "AUTO"
    }

    result_configuration {
      output_location = "s3://${var.primary.query_result_bucket_id}/"
    }
  }
}
