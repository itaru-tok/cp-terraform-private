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

module "cloud_scheduler" {
  source     = "../service_account_unit"
  project    = var.project
  account_id = "cloud-scheduler-${var.env}"
  roles = [
    "roles/run.jobsExecutorWithOverrides"
  ]
}

module "cloud_tasks" {
  source     = "../service_account_unit"
  project    = var.project
  account_id = "cloud-tasks-${var.env}"
  roles = [
    "roles/run.invoker",
  ]
}

module "hive_converter" {
  source     = "../service_account_unit"
  project    = var.project
  account_id = "ec-hive-converter-${var.env}"
  roles = [
    "roles/storage.objectUser",
  ]
}

module "hive_converter_trigger" {
  source     = "../service_account_unit"
  project    = var.project
  account_id = "ec-hive-converter-trigger-${var.env}"
  roles = [
    "roles/run.invoker",
    "roles/eventarc.eventReceiver",
    "roles/storage.bucketViewer",
  ]
}

resource "google_project_iam_member" "cloud_build_storage_object_viewer" {
  project = var.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:cloud-build-${var.env}@${var.project}.iam.gserviceaccount.com"
}
