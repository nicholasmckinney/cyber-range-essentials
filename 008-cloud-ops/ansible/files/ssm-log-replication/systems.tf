resource "aws_iam_role" "replication_role" {
  provider = aws.systems
  name     = "ssm-log-replication"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_kms_key" "source_ssm_logs" {
  provider = aws.systems
  key_id   = "alias/ssm_logs"
}

data "aws_kms_key" "source_ssm_communications" {
  provider = aws.systems
  key_id   = "alias/ssm_communications"
}

data "aws_s3_bucket" "source_ssm_logs" {
  provider = aws.systems
  bucket   = "${var.systems_account_id}-ssm-logs"
}

resource "aws_s3_bucket_replication_configuration" "replication_configuration" {
  provider = aws.systems
  role   = aws_iam_role.replication_role.arn
  bucket = data.aws_s3_bucket.source_ssm_logs.id
  depends_on = [ aws_s3_bucket.vault_ssm_logs, aws_s3_bucket_policy.vault_ssm_logs_policy ]

  rule {
    id       = "ReplicateToVault"
    priority = 0
    status   = "Enabled"

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }

    destination {
      bucket = aws_s3_bucket.vault_ssm_logs.arn
      storage_class = "GLACIER"

      access_control_translation {
        owner = "Destination"
      }

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.vault_ssm_logs_key.arn
      }

      account = "${var.vault_account_id}"
    }

  }
}

resource "aws_iam_policy" "replication_policy" {
  provider   = aws.systems  
  
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectVersion",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ]
        Resource = [
          "${data.aws_s3_bucket.source_ssm_logs.arn}",
          "${data.aws_s3_bucket.source_ssm_logs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateTags",
          "s3:GetObjectVersionTagging",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ]
        Resource = "${aws_s3_bucket.vault_ssm_logs.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [ data.aws_kms_key.source_ssm_logs.arn, data.aws_kms_key.source_ssm_communications.arn ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt"
        ]
        Resource = aws_kms_key.vault_ssm_logs_key.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  provider   = aws.systems
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn 
}
