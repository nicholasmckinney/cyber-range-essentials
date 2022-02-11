terraform {
  backend "s3" {
    bucket = "avid-security-com-terraform-state"
    key    = "hybrid_management.tfstate"
    region = "us-east-1"
  }
}
