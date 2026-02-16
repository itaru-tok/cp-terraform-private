output "rds_cp_initial_password" {
  value       = module.rds.password
  sensitive   = true
  description = "RDS cloud-praticaの初期パスワード"
}
