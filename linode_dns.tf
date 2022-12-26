resource "linode_domain" "evilfactorylabs_social" {
  domain    = "evilfactorylabs.social"
  soa_email = "hostmaster@evilfactorylabs.org"
  type      = "master"
}

resource "linode_domain_record" "evilfactorylabs_social_apex" {
  domain_id   = linode_domain.evilfactorylabs_social.id
  target      = linode_instance.evilfactorylabs_social.ip_address
  record_type = local.dns_record.a
}

resource "linode_domain_record" "evilfactorylabs_social_s3" {
  domain_id   = linode_domain.evilfactorylabs_social.id
  name        = "s3"
  target      = linode_instance.evilfactorylabs_social.ip_address
  record_type = local.dns_record.a
}

resource "linode_domain_record" "evilfactorylabs_social_mailgun_mx" {
  for_each    = { for i, v in local.mailgun_mx : i => v }
  domain_id   = linode_domain.evilfactorylabs_social.id
  record_type = local.dns_record.mx

  name     = trim(each.value.domain, ".")
  target   = "mg.evilfactorylabs.social"
  priority = each.value.priority
}

resource "linode_domain_record" "evilfactorylabs_social_mailgun_cname" {
  domain_id   = linode_domain.evilfactorylabs_social.id
  record_type = local.dns_record.cname

  name   = "email.mg"
  target = "eu.mailgun.org"
}

resource "linode_domain_record" "evilfactorylabs_social_mailgun_spf" {
  domain_id   = linode_domain.evilfactorylabs_social.id
  record_type = local.dns_record.txt

  name   = "mg"
  target = "v=spf1 include:mailgun.org ~all"
}

resource "linode_domain_record" "evilfactorylabs_social_mailgun_dkim" {
  domain_id   = linode_domain.evilfactorylabs_social.id
  record_type = local.dns_record.txt

  name   = "mta._domainkey.mg"
  target = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCrPKiwLlHzORW+15yUzFqA3qaVqs8oCmz69hNOaEx5sAnxpP7GpVvapEB/Bt2LNb1memDHcNfwwc7aUYI7YYUAQtPB8Tmfy1p91skVIdeNpJ3TM8qemKmZ3JIeO/JztzOIwwUjUY8dg7OuoP9zJAK/JU6lcbpdDBHUpSVEYqBsKQIDAQAB"
}
