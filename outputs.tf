output "evilfactorylabs_forem_ip" {
  value = data.digitalocean_droplet.forem.ipv4_address
}

output "evilfactorylabs_forem_vpc" {
  value = data.digitalocean_droplet.forem.vpc_uuid
}

output "evilfactorylabs_forem_region" {
  value = data.digitalocean_droplet.forem.region
}

output "evilfactorylabs_forem_image_id" {
  value = data.digitalocean_droplet.forem.image
}

