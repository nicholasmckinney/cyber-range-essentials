locals {
  read_only_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role" "root_readonly_user" {
  provider           = aws.root
  name               = "federated-readonly-user"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.security_operations_sso.arn)
}

resource "aws_iam_role" "security_readonly_user" {
  provider           = aws.security
  name               = "federated-readonly-user"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.security_operations_sso.arn)
}

resource "aws_iam_role" "systems_readonly_user" {
  provider           = aws.systems
  name               = "federated-readonly-user"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.systems_operations_sso.arn)
}

resource "aws_iam_role" "vault_readonly_user" {
  provider           = aws.vault
  name               = "federated-readonly-user"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.vault_sso.arn)
}

resource "aws_iam_role_policy_attachment" "root_readonly_user_policy_attachment" {
  provider  = aws.root
  role       = aws_iam_role.root_readonly_user.name
  policy_arn = local.read_only_policy_arn
}

resource "aws_iam_role_policy_attachment" "security_readonly_user_policy_attachment" {
  provider   = aws.security
  role       = aws_iam_role.security_readonly_user.name
  policy_arn = local.read_only_policy_arn
}

resource "aws_iam_role_policy_attachment" "systems_readonly_user_policy_attachment" {
  provider   = aws.systems
  role       = aws_iam_role.systems_readonly_user.name
  policy_arn = local.read_only_policy_arn
}

resource "aws_iam_role_policy_attachment" "vault_readonly_user_policy_attachment" {
  provider   = aws.vault
  role       = aws_iam_role.vault_readonly_user.name
  policy_arn = local.read_only_policy_arn
}
