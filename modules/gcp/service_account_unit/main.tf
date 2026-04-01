resource "google_service_account" "main" {
  account_id   = var.account_id
  display_name = var.account_id
  project      = var.project
}

// MEMO: サービスアカウントに対してロールを付与
resource "google_project_iam_member" "main" {
  project = var.project
  member  = "serviceAccount:${google_service_account.main.email}"

  for_each = toset(var.roles)
  role     = each.value
}
