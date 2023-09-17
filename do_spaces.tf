resource "digitalocean_spaces_bucket" "evilfactorylabs-social" {
  name               = "evilfactorylabs-social"
  region             = "sgp1"

  versioning {
    enabled = false
  }
}
