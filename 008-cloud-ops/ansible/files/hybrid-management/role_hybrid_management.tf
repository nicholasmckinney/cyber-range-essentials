resource "aws_iam_role" "hybrid_management" {
  provider           = aws.systems
  name               = "hybrid-management"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ssm.amazonaws.com"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "aws:SourceAccount": "${var.systems_account_id}"
          },
          "ArnEquals": {
            "aws:SourceArn": "arn:aws:ssm:${var.region}:${var.systems_account_id}:*"
          }
        }
      }
    ]
}
  EOF
}

resource "aws_iam_policy" "hybrid_management" {
  provider    = aws.systems
  name        = "hybrid-management-policy"
  depends_on  = [ aws_kms_key.ssm_key ]

  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [ "${aws_s3_bucket.ssm_logs.arn}/*" ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetEncryptionConfiguration"
        ]
        Resource = [ aws_s3_bucket.ssm_logs.arn ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt"
        ],
        Resource = [ aws_kms_key.ssm_key.arn, aws_kms_key.log_encryption_key.arn ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "*"
      },


      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeAssociation",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:DescribeDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutInventory",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      },


      {
        Effect = "Allow"
        Action = [
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply" 
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "hybrid_management" {
  provider   = aws.systems
  role       = aws_iam_role.hybrid_management.name
  policy_arn = aws_iam_policy.hybrid_management.arn
}

resource "aws_ssm_activation" "hybrid_management" {
  provider            = aws.systems
  name                = "hybrid_management"
  description         = "Used to activate on-premises servers with SSM"
  iam_role            = aws_iam_role.hybrid_management.id
  registration_limit  = 10 
  depends_on          = [aws_iam_role.hybrid_management, aws_iam_role_policy_attachment.hybrid_management]
}

output "ssm_activation_code" {
  value = aws_ssm_activation.hybrid_management.activation_code
}

output "ssm_activation_id" {
  value = aws_ssm_activation.hybrid_management.id
}
