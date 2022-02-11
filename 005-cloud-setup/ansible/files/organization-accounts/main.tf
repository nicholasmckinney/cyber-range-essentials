variable "domain" {}
variable "region" {}

provider "aws" {
  region = var.region
}

resource "aws_organizations_account" "systems_management" {
  name  = "systems-operations"
  email = "systems-operations@${var.domain}"
}

resource "aws_organizations_account" "security" {
  name  = "security-operations"
  email = "security-operations@${var.domain}"
}

resource "aws_organizations_account" "logs" {
  name  = "vault"
  email = "vault@${var.domain}"
}
