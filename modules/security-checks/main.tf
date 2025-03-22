provider "aws" {
  region = var.region
}

resource "aws_config_configuration_recorder" "recorder" {
  name     = "terraform-${var.environment}-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "channel" {
  name           = "terraform-${var.environment}-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  depends_on     = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.channel]
}

resource "aws_iam_role" "config_role" {
  name = "terraform-${var.environment}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "terraform-${var.environment}-config-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:GetBucketAcl"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Action = "s3:PutObject"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Resource = "${aws_s3_bucket.config_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

# AWS Config 규칙
resource "aws_config_config_rule" "s3_bucket_public_write_prohibited" {
  name = "s3-bucket-public-write-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  name = "iam-root-access-key-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# AWS CloudTrail 통합
resource "aws_cloudwatch_event_rule" "config_compliance" {
  name        = "terraform-${var.environment}-compliance-change"
  description = "Capture AWS Config compliance changes"

  event_pattern = jsonencode({
    source      = ["aws.config"]
    detail_type = ["Config Rules Compliance Change"]
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.config_compliance.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.config_alerts.arn
}

resource "aws_sns_topic" "config_alerts" {
  name = "terraform-${var.environment}-config-alerts"
}