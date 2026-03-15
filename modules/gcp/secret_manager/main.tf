resource "google_secret_manager_secret" "db_cloud_pratica_host" {
  project   = var.project
  secret_id = "db-cloud-pratica-host-${var.env}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "db_slack_metrics_user" {
  project   = var.project
  secret_id = "db-slack-metrics-user-${var.env}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "db_slack_metrics_password" {
  project   = var.project
  secret_id = "db-slack-metrics-password-${var.env}"
  replication {
    auto {}
  }
}
