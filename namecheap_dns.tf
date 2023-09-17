resource "namecheap_domain_records" "evilfactorylabs-org" {
  domain = digitalocean_domain.evilfactorylabs.name
  mode   = "OVERWRITE"

  nameservers = var.dns_authoritative_nameservers
}

resource "namecheap_domain_records" "evilfactorylabs-social" {
  domain = digitalocean_domain.evilfactorylabs_social.name
  mode   = "OVERWRITE"

  nameservers = var.dns_authoritative_nameservers
}

resource "namecheap_domain_records" "evlfctry-pro" {
  domain = digitalocean_domain.evlfctrypro.name
  mode   = "OVERWRITE"

  nameservers = var.dns_authoritative_nameservers
}
