output "sns_topic_arn" {
  value       = aws_sns_topic.config_alerts.arn
  description = "The ARN of the SNS topic for config alerts"
}

output "config_bucket_name" {
  value       = aws_s3_bucket.config_bucket.bucket
  description = "The name of the config bucket"
}     