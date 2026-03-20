resource "google_cloud_scheduler_job" "slack_metrics_sync_workspaces" {
  name    = "slack-metrics-sync-workspaces-${var.env}"
  region  = "asia-northeast1"
  project = var.project

  http_target {
    uri         = "https://import-placeholder.invalid/"
    http_method = "POST"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "google_cloud_scheduler_job" "slack_metrics_sync_users" {
  name    = "slack-metrics-sync-users-${var.env}"
  region  = "asia-northeast1"
  project = var.project

  http_target {
    uri         = "https://import-placeholder.invalid/"
    http_method = "POST"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "google_cloud_scheduler_job" "cost_cutter_stop_db_instance_cp" {
  name    = "scheduler-cost-cutter-${var.env}"
  region  = "asia-northeast1"
  project = var.project

  http_target {
    uri         = "https://import-placeholder.invalid/"
    http_method = "POST"
  }

  lifecycle {
    ignore_changes = all
  }
}
