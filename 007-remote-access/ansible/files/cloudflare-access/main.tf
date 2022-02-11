variable "lab_domain" {}

provider "cloudflare" {
}

data "cloudflare_zones" "zones" {
  filter {
    name = var.lab_domain
  }
}

resource "cloudflare_access_application" "proxmox" {
  zone_id = data.cloudflare_zones.zones.zones[0].id
  name    = "Proxmox"
  domain  = "proxmox.${var.lab_domain}"
}

resource "cloudflare_access_application" "rdp" {
  zone_id = data.cloudflare_zones.zones.zones[0].id
  name    = "Remote Desktop Protocol"
  domain  = "rdp.${var.lab_domain}"
}


resource "cloudflare_access_policy" "proxmox_domain_email_policy" {
  zone_id        = data.cloudflare_zones.zones.zones[0].id
  application_id = cloudflare_access_application.proxmox.id
  name           = "Proxmox Organization Email Policy"
  decision       = "allow"
  precedence     = 1

  include {
    email_domain = [var.lab_domain]
  }
}

resource "cloudflare_access_policy" "rdp_domain_email_policy" {
  zone_id         = data.cloudflare_zones.zones.zones[0].id
  application_id  = cloudflare_access_application.rdp.id
  name            = "RDP Organization Email Policy"
  decision        = "allow"
  precedence      = 1

  include {
    email_domain  = [var.lab_domain]
  } 
}
