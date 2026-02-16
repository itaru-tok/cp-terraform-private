output "password" {
  value     = random_password.db.result
  sensitive = true
}
