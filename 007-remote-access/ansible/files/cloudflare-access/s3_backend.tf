terraform {
  backend "s3" {
    bucket = "avid-security-com-terraform-state"
    key    = "cloudflare_access.tfstate"
    region = "us-east-1"
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2"
    }
  }
}
