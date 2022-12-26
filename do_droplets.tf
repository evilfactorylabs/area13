resource "digitalocean_droplet" "forem" {
  name   = "www.evilfactorylabs.org"
  image  = "88327586"
  region = "sgp1"
  size   = "s-2vcpu-2gb"
}
