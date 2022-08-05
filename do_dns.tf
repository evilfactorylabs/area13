locals {
  dns_record = {
    a     = "A"
    ns    = "NS"
    mx    = "MX"
    txt   = "TXT"
    cname = "CNAME"
  }

  migadu_dkim = ["key1", "key2", "key3"]

  migadu_mx = [{
    domain   = "aspmx1.migadu.com.",
    priority = 10
    },
    {
      domain   = "aspmx2.migadu.com.",
      priority = 20
  }]

  mailgun_mx = [{
    domain   = "mxa.eu.mailgun.org.",
    priority = 10
    },
    {
      domain   = "mxb.eu.mailgun.org.",
      priority = 10
  }]
}

resource "digitalocean_domain" "evilfactorylabs" {
  name = "evilfactorylabs.org"

  ip_address = data.digitalocean_droplet.forem.ipv4_address
}

resource "digitalocean_record" "evilfactorylabs_ns" {
  for_each = toset(var.dns_authoritaive_nameservers)
  domain   = digitalocean_domain.evilfactorylabs.id
  type     = local.dns_record.ns

  name  = "@"
  value = "${each.value}."
}

resource "digitalocean_record" "evilfactorylabs_www" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.a

  name  = "www"
  value = data.digitalocean_droplet.forem.ipv4_address
}

resource "digitalocean_record" "evilfactorylabs_about" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.cname

  name  = "about"
  value = "cname.vercel-dns.com."
}

resource "digitalocean_record" "evilfactorylabs_handbook" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.cname

  name  = "handbook"
  value = "cname.vercel-dns.com."
}

resource "digitalocean_record" "evilfactorylabs_resources" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.cname

  name  = "resources"
  value = "evilfactorylabs.github.io."
}

resource "digitalocean_record" "evilfactorylabs_migadu_cname" {
  for_each = toset(local.migadu_dkim)
  domain   = digitalocean_domain.evilfactorylabs.id
  type     = local.dns_record.cname

  name  = "${each.value}._domainkey"
  value = "${each.value}.${digitalocean_domain.evilfactorylabs.name}._domainkey.migadu.com."
}

resource "digitalocean_record" "evilfactorylabs_mailgun_cname" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.cname

  name  = "email.mg"
  value = "eu.mailgun.org."
}

resource "digitalocean_record" "evilfactorylabs_migadu_mx" {
  for_each = { for i, v in local.migadu_mx : i => v }
  domain   = digitalocean_domain.evilfactorylabs.id
  type     = local.dns_record.mx

  name     = "@"
  value    = each.value.domain
  priority = each.value.priority
}

resource "digitalocean_record" "evilfactorylabs_mailgun_mx" {
  for_each = { for i, v in local.mailgun_mx : i => v }
  domain   = digitalocean_domain.evilfactorylabs.id
  type     = local.dns_record.mx

  name     = "@"
  value    = each.value.domain
  priority = each.value.priority
}

resource "digitalocean_record" "evilfactorylabs_github_domain_verification" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.txt

  name  = "_github-challenge-evilfactorylabs"
  value = "43cafecc15"
}

resource "digitalocean_record" "evilfactorylabs_migadu_spf" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.txt

  name  = "@"
  value = "v=spf1 include:spf.migadu.com -all"
}

resource "digitalocean_record" "evilfactorylabs_mailgun_spf" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.txt

  name  = "mg"
  value = "v=spf1 include:mailgun.org ~all"
}

resource "digitalocean_record" "evilfactorylabs_dmarc" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.txt

  name  = "@"
  value = "v=DMARC1; p=quarantine;"
}

resource "digitalocean_record" "evilfactorylabs_migadu_dkim" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.txt

  name  = "@"
  value = "hosted-email-verify=f8hrl46d"
}

resource "digitalocean_record" "evilfactorylabs_mailgun_dkim" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.txt

  name  = "mta._domainkey.mg"
  value = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDE2EiU3PrqyJsZfz1MM+LRKTqy9tkjCeVeqY8pZjbOskZ/QdBQI308l1i7i2AQ16GvJK16NgnyT/g+kcCwFHLt5rmh4h/1jyO/Jl6Q+s9Sfqgo3RMZc9jQ5I+6hwU47wU1zLrvrPefuGCwF+sCvFvRBS80fQP15GTAoSuiZN4LyQIDAQAB"
}
