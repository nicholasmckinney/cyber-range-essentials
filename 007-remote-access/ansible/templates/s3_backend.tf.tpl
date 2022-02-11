terraform {
  backend "s3" {
    bucket = "{{ terraform_bucket }}"
    key    = "{{ terraform_state_key }}"
    region = "{{ region }}"
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2"
    }
  }
}
