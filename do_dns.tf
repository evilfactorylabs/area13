locals {
  dns_record = {
    a     = "A"
    ns    = "NS"
    mx    = "MX"
    txt   = "TXT"
    cname = "CNAME"
  }

  // https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site#configuring-an-apex-domain
  github_pages_apex_ip = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]

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

  ip_address = resource.digitalocean_droplet.forem.ipv4_address
}

resource "digitalocean_record" "evilfactorylabs_ns" {
  for_each = toset(var.dns_authoritative_nameservers)
  domain   = digitalocean_domain.evilfactorylabs.id
  type     = local.dns_record.ns

  name  = "@"
  value = "${each.value}."
}

resource "digitalocean_record" "evilfactorylabs_www" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.a

  name  = "www"
  value = resource.digitalocean_droplet.forem.ipv4_address
}

resource "digitalocean_record" "evilfactorylabs_atlantis" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.cname

  name  = "atlantis"
  value = "cname.edgy.network."
}

resource "digitalocean_record" "evilfactorylabs_localhost" {
  domain = digitalocean_domain.evilfactorylabs.id
  type   = local.dns_record.a

  name  = "localhost"
  value = "127.0.0.1"
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

resource "digitalocean_domain" "evlfctrypro" {
  name = "evlfctry.pro"
}

resource "digitalocean_record" "evlfctrypro_apex" {
  for_each = toset(local.github_pages_apex_ip)
  domain   = digitalocean_domain.evlfctrypro.id
  type     = local.dns_record.a

  name  = "@"
  value = each.value
}

resource "digitalocean_record" "evlfctrypro_www" {
  domain = digitalocean_domain.evlfctrypro.id
  type   = local.dns_record.cname

  name  = "www"
  value = "evilfactorylabs.github.io."
}

resource "digitalocean_record" "evlfctrypro_github_domain_verification" {
  domain = digitalocean_domain.evlfctrypro.id
  type   = local.dns_record.txt

  name  = "_github-challenge-evilfactorylabs"
  value = "877b53fd61"
}

resource "digitalocean_domain" "evilfactorylabs_social" {
  name = "evilfactorylabs.social"
}

resource "digitalocean_record" "evilfactorylabs_social_apex" {
  domain = digitalocean_domain.evilfactorylabs_social.id
  type   = local.dns_record.a

  name  = "@"
  value = resource.digitalocean_droplet.evilfactorylabs_social.ipv4_address
}

resource "digitalocean_record" "evilfactorylabs_social_u" {
  domain = digitalocean_domain.evilfactorylabs_social.id
  type   = local.dns_record.a

  name  = "u"
  value = resource.digitalocean_droplet.evilfactorylabs_social.ipv4_address
}

resource "digitalocean_record" "evilfactorylabs_social_cdn" {
  domain = digitalocean_domain.evilfactorylabs_social.id
  type   = local.dns_record.cname

  name  = "cdn"
  value = "evilfactorylabs-social-sgp1-digitaloceanspaces.b-cdn.net."
}

resource "digitalocean_record" "evilfactorylabs_social_mailgun" {
  domain = digitalocean_domain.evilfactorylabs_social.id
  type   = local.dns_record.cname

  name  = "email.mg"
  value = "eu.mailgun.org."
}

resource "digitalocean_record" "evilfactorylabs_social_mailgun_mx" {
  for_each = { for i, v in local.mailgun_mx : i => v }
  domain   = digitalocean_domain.evilfactorylabs_social.id
  type     = local.dns_record.mx

  name     = "@"
  value    = each.value.domain
  priority = each.value.priority
}

resource "digitalocean_record" "evilfactorylabs_social_mailgun_spf" {
  domain = digitalocean_domain.evilfactorylabs_social.id
  type   = local.dns_record.txt

  name  = "mg"
  value = "v=spf1 include:mailgun.org ~all"
}

resource "digitalocean_record" "evilfactorylabs_social_mailgun_dkim" {
  domain = digitalocean_domain.evilfactorylabs_social.id
  type   = local.dns_record.txt

  name  = "mta._domainkey.mg"
  value = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCrPKiwLlHzORW+15yUzFqA3qaVqs8oCmz69hNOaEx5sAnxpP7GpVvapEB/Bt2LNb1memDHcNfwwc7aUYI7YYUAQtPB8Tmfy1p91skVIdeNpJ3TM8qemKmZ3JIeO/JztzOIwwUjUY8dg7OuoP9zJAK/JU6lcbpdDBHUpSVEYqBsKQIDAQAB"
}
