variable "env" {
  type = string
}

variable "primary" {
  type = object({
    query_result_bucket_id = string
  })
  description = "primary ワークグループのクエリ結果出力先バケット名（cp-athena-query-result-itaru-{env}）"
}
