output "id_alb" {
  value = aws_security_group.alb.id
}

output "id_bastion" {
  value = aws_security_group.bastion.id
}

output "id_nat" {
  value = aws_security_group.nat.id
}

output "id_slack_metrics_backend" {
  value = aws_security_group.slack_metrics_backend.id
}

output "id_slack_metrics_lambda" {
  value = aws_security_group.slack_metrics_lambda.id
}

output "id_db_migrator" {
  value = aws_security_group.db_migrator.id
}

output "id_db" {
  value = aws_security_group.db.id
}

output "id_media_compressor_compress_video" {
  value = aws_security_group.media_compressor_compress_video.id
}

output "id_batch" {
  value = aws_security_group.batch.id
}
