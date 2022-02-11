resource "aws_kms_key" "log_encryption_key" {
  provider = aws.systems
  description = "Used to encrypt SSM session log data"
  enable_key_rotation = true
}

resource "aws_kms_alias" "log_encryption_key" {
  provider      = aws.systems
  name          = "alias/ssm_logs"
  target_key_id = aws_kms_key.log_encryption_key.key_id
}

resource "aws_s3_bucket" "ssm_logs" {
  provider = aws.systems
  bucket   = "${var.systems_account_id}-ssm-logs"
  acl      = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    ignore_changes = [
      replication_configuration 
    ]
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.log_encryption_key.arn
        sse_algorithm = "aws:kms"
      }
    }
  }
}
