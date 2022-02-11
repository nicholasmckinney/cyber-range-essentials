resource "aws_kms_key" "vault_ssm_logs_key" {
  provider = aws.vault

  policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.vault_account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Enable cross account encrypt access for S3 Cross Region Replication",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.systems_account_id}:root"
      },
      "Action": [
        "kms:Encrypt"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_kms_alias" "vault_ssm_logs_key" {
  provider      = aws.vault
  name          = "alias/ssm_logs"
  target_key_id = aws_kms_key.vault_ssm_logs_key.key_id
}

resource "aws_s3_bucket" "vault_ssm_logs" {
  provider = aws.vault
  bucket = "${var.vault_account_id}-ssm-logs"
  acl      = "private"
  
  versioning {
    enabled = true
    mfa_delete = true
  } 

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.vault_ssm_logs_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "vault_ssm_logs_policy" {
  provider = aws.vault
  bucket = aws_s3_bucket.vault_ssm_logs.id
  depends_on = [ aws_s3_bucket.vault_ssm_logs ]

  policy = data.aws_iam_policy_document.allow_access_from_systems_account.json
}

data "aws_iam_policy_document" "allow_access_from_systems_account" {
  statement {
    sid = "AllowReplication"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.systems_account_id}:root"]
    }
    
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]

    resources = [
      "${aws_s3_bucket.vault_ssm_logs.arn}/*"
    ]
  }

  statement {
    sid = "AllowRead"
    effect = "Allow"
    
    principals {
      type = "AWS"
      identifiers = [ "arn:aws:iam::${var.systems_account_id}:root" ]
    }

    actions = [ "s3:List*", "s3:GetBucketVersioning", "s3:PutBucketVersioning" ]
  
    resources = [ "${aws_s3_bucket.vault_ssm_logs.arn}" ]
  }
}
