locals {
  sso_provider                = "google-provider"
  saml_metadata_file     = "../../../../shared/GoogleIDPMetadata.xml"
  assume_role_policy_template = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRoleWithSAML",
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "SAML:aud": "https://signin.aws.amazon.com/saml"
                }
            },
            "Principal": {
                "Federated": "%s"
            }
        }
    ]
}
EOF
}

resource "aws_iam_saml_provider" "root_sso" {
  provider               = aws.root
  name                   = local.sso_provider
  saml_metadata_document = file(local.saml_metadata_file)
}

resource "aws_iam_saml_provider" "security_operations_sso" {
  provider               = aws.security
  name                   = local.sso_provider
  saml_metadata_document = file(local.saml_metadata_file)
}

resource "aws_iam_saml_provider" "systems_operations_sso" {
  provider               = aws.systems
  name                   = local.sso_provider
  saml_metadata_document = file(local.saml_metadata_file)
}

resource "aws_iam_saml_provider" "vault_sso" {
  provider               = aws.vault
  name                   = local.sso_provider
  saml_metadata_document = file(local.saml_metadata_file)
}
