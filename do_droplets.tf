resource "digitalocean_droplet" "forem" {
  name   = "www.evilfactorylabs.org"
  image  = "88327586"
  region = "sgp1"
  size   = "s-2vcpu-2gb"
}

resource "digitalocean_droplet" "evilfactorylabs_social" {
  name   = "evilfactorylabs.social"
  image  = "ubuntu-22-04-x64"
  region = "sgp1"
  size   = "s-2vcpu-4gb"
}
