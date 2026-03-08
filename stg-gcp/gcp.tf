module "service_account" {
  source  = "../modules/gcp/service_account"
  project = local.project
  env     = local.env
}
