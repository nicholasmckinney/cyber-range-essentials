variable "region" {}
variable "zone" {}

provider "aws" {
  region = var.region
}

# provided by environmental variables
provider "cloudflare" {
}

resource "cloudflare_zone" "zone" {
  zone = var.zone
}

resource "cloudflare_record" "spf" {
  zone_id   = cloudflare_zone.zone.id
  name      = "@"
  value     = "v=spf1 include:_spf.google.com ~all"
  ttl       = 3600
  type      = "TXT"
}

resource "cloudflare_record" "mx1" {
  zone_id   = cloudflare_zone.zone.id
  name      = "@"
  value     = "ASPMX.L.GOOGLE.COM"
  ttl       = 3600
  type      = "MX"
  priority  = 1
}

resource "cloudflare_record" "mx2" {
  zone_id   = cloudflare_zone.zone.id
  name      = "@"
  value     = "ALT1.ASPMX.L.GOOGLE.COM"
  ttl       = 3600
  type      = "MX"
  priority  = 5
}

resource "cloudflare_record" "mx3" {
  zone_id   = cloudflare_zone.zone.id
  name      = "@"
  value     = "ALT2.ASPMX.L.GOOGLE.COM"
  ttl       = 3600
  type      = "MX"
  priority  = 5
}

resource "cloudflare_record" "mx4" {
  zone_id   = cloudflare_zone.zone.id
  name      = "@"
  value     = "ALT3.ASPMX.L.GOOGLE.COM"
  ttl       = 3600
  type      = "MX"
  priority  = 10
}

resource "cloudflare_record" "mx5" {
  zone_id   = cloudflare_zone.zone.id
  name      = "@"
  value     = "ALT4.ASPMX.L.GOOGLE.COM"
  ttl       = 3600
  type      = "MX"
  priority  = 10
}

data "cloudflare_api_token_permission_groups" "all" {}

resource "cloudflare_api_token" "caddy_dns_write" {
  name  = "caddy_dns_write"
  
  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.permissions["Zone Read"],
      data.cloudflare_api_token_permission_groups.all.permissions["DNS Write"]
    ]
  
    resources = {
      "com.cloudflare.api.account.zone.${cloudflare_zone.zone.id}" = "*"
    }
  }

}

output "caddy_token" {
  value     = cloudflare_api_token.caddy_dns_write.value
  sensitive = true
}
