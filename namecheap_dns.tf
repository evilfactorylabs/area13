resource "namecheap_domain_records" "evilfactorylabs-org" {
  domain = digitalocean_domain.evilfactorylabs.name
  mode   = "OVERWRITE"

  nameservers = var.dns_authoritaive_nameservers
}