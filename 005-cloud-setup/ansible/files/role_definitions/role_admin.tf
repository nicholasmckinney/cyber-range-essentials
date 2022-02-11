locals {
  admin_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "root_admin" {
  provider           = aws.root
  name               = "federated-admin"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.root_sso.arn)
}

resource "aws_iam_role" "security_admin" {
  provider           = aws.security
  name               = "federated-admin"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.security_operations_sso.arn)
}

resource "aws_iam_role" "systems_admin" {
  provider           = aws.systems
  name               = "federated-admin"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.systems_operations_sso.arn)
}

resource "aws_iam_role" "vault_admin" {
  provider           = aws.vault
  name               = "federated-admin"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.vault_sso.arn)
}

resource "aws_iam_role_policy_attachment" "root_admin_policy_attachment" {
  provider   = aws.root
  role       = aws_iam_role.root_admin.name
  policy_arn = local.admin_policy_arn
}

resource "aws_iam_role_policy_attachment" "security_admin_policy_attachment" {
  provider   = aws.security
  role       = aws_iam_role.security_admin.name
  policy_arn = local.admin_policy_arn
}

resource "aws_iam_role_policy_attachment" "systems_admin_policy_attachment" {
  provider   = aws.systems
  role       = aws_iam_role.systems_admin.name
  policy_arn = local.admin_policy_arn
}

resource "aws_iam_role_policy_attachment" "vault_admin_policy_attachment" {
  provider   = aws.vault
  role       = aws_iam_role.vault_admin.name
  policy_arn = local.admin_policy_arn
}
