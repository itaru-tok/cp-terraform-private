module "service_account" {
  source  = "../modules/gcp/service_account"
  project = local.project
  env     = local.env
}

module "secret_manager" {
  source  = "../modules/gcp/secret_manager"
  project = local.project
  env     = local.env
}
