locals {
  power_user_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role" "root_power_user" {
  provider           = aws.root
  name               = "federated-power-user"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.root_sso.arn)
}

resource "aws_iam_role" "security_power_user" {
  provider           = aws.security
  name               = "federated-power-user"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.security_operations_sso.arn)
}

resource "aws_iam_role" "systems_power_user" {
  provider           = aws.systems
  name               = "federated-power-user"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.systems_operations_sso.arn)
}

resource "aws_iam_role" "vault_power_user" {
  provider           = aws.vault
  name               = "federated-power-user"
  assume_role_policy = format(local.assume_role_policy_template, aws_iam_saml_provider.vault_sso.arn)
}

resource "aws_iam_role_policy_attachment" "root_power_user_policy_attachment" {
  provider   = aws.root
  role       = aws_iam_role.root_power_user.name
  policy_arn = local.power_user_policy_arn
}

resource "aws_iam_role_policy_attachment" "security_power_user_policy_attachment" {
  provider   = aws.security
  role       = aws_iam_role.security_power_user.name
  policy_arn = local.power_user_policy_arn
}

resource "aws_iam_role_policy_attachment" "systems_power_user_policy_attachment" {
  provider   = aws.systems
  role       = aws_iam_role.systems_power_user.name
  policy_arn = local.power_user_policy_arn
}

resource "aws_iam_role_policy_attachment" "vault_power_user_policy_attachment" {
  provider   = aws.vault
  role       = aws_iam_role.vault_power_user.name
  policy_arn = local.power_user_policy_arn
}
