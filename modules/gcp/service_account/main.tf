module "slack_metrics_backend" {
  source     = "../service_account_unit"
  project    = var.project
  account_id = "slack-metrics-backend-${var.env}"
  roles = [
    "roles/secretmanager.secretAccessor",
    "roles/cloudtasks.enqueuer",
    "roles/iam.serviceAccountUser"
  ]
}

module "db_migrator" {
  source     = "../service_account_unit"
  project    = var.project
  account_id = "db-migrator-${var.env}"
  roles = [
    "roles/secretmanager.secretAccessor",
  ]
}
