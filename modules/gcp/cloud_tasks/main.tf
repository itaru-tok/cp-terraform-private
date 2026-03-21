resource "google_cloud_tasks_queue" "slack_metrics_sync_workspace" {
  name     = "slack-metrics-sync-workspace-${var.env}"
  location = "asia-northeast1"
  project  = var.project

  lifecycle {
    ignore_changes = all
  }
}
