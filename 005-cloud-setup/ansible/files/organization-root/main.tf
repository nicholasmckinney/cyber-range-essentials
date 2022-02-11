variable "region" {}

provider "aws" {
  region = var.region
}

resource "aws_organizations_organization" "organization" {
    aws_service_access_principals = [
      "access-analyzer.amazonaws.com",
      "cloudtrail.amazonaws.com",
      "config.amazonaws.com",
      "guardduty.amazonaws.com",
      "sso.amazonaws.com",
      "tagpolicies.tag.amazonaws.com"
    ]

    feature_set = "ALL"
}
