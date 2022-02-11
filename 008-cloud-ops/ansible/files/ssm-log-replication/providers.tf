locals {
  session_name   = "ansible"
  org_admin_role = "arn:aws:iam::%s:role/OrganizationAccountAccessRole"
}

provider "aws" {
  alias  = "root"
  region = var.region
}

provider "aws" {
  alias  = "systems"
  region = var.region
  assume_role {
    role_arn     = format(local.org_admin_role, var.systems_account_id)
    session_name = local.session_name
  }
}

provider "aws" {
  alias  = "vault"
  region = var.region
  assume_role {
    role_arn = format(local.org_admin_role, var.vault_account_id)
    session_name = local.session_name
  }
}
