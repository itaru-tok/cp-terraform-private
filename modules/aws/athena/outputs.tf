output "workgroup_name_primary" {
  value = aws_athena_workgroup.primary.name
}

output "workgroup_arn_primary" {
  value = aws_athena_workgroup.primary.arn
}
