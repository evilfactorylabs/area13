output "evilfactorylabs_forem_ip" {
  value = resource.digitalocean_droplet.forem.ipv4_address
}

output "evilfactorylabs_forem_vpc" {
  value = resource.digitalocean_droplet.forem.vpc_uuid
}

output "evilfactorylabs_forem_region" {
  value = resource.digitalocean_droplet.forem.region
}

output "evilfactorylabs_forem_image_id" {
  value = resource.digitalocean_droplet.forem.image
}

output "evilfactorylabs_social_ip" {
  value = resource.linode_instance.evilfactorylabs_social.ip_address
}

output "evilfactorylabs_social_region" {
  value = resource.linode_instance.evilfactorylabs_social.region
}
