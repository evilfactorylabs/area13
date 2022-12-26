resource "digitalocean_vpc" "default_sgp" {
  name     = "default-sgp1"
  ip_range = "10.104.0.0/20"
  region   = "sgp1"
}
