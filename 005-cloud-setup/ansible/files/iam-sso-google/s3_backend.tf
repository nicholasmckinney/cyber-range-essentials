terraform {
  backend "s3" {
    bucket = "avid-security-com-terraform-state"
    key    = "iam_sso.tfstate"
    region = "us-east-1"
  }
}
