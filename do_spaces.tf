resource "digitalocean_spaces_bucket" "evilfactorylabs-social" {
  bucket_domain_name = "evilfactorylabs-social.sgp1.digitaloceanspaces.com"
  id                 = "evilfactorylabs-social"
  name               = "evilfactorylabs-social"
  region             = "sgp1"
  urn                = "do:space:evilfactorylabs-social"

  versioning {
    enabled = false
  }
}
