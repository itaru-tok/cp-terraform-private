resource "google_project_iam_custom_role" "bigquery_dataset_editor" {
  project     = var.project
  role_id     = "bigquery.datasetEditor"
  title       = "BigQuery Dataset 編集者"
  description = "BigQuery Datasetの編集を行うためのカスタムロール"
  permissions = [
    "bigquery.datasets.get",
    "bigquery.datasets.update",
  ]
}
