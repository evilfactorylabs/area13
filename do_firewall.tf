locals {
  allowed_subnets = {
    internet = "0.0.0.0/0"
    tailnet  = "100.64.0.0/10"
  }

  allowed_inbounds = [{
    name             = "SSH"
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [local.allowed_subnets.internet]
    },
    {
      name             = "HTTP",
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = [local.allowed_subnets.internet]
    },
    {
      name             = "HTTPS",
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = [local.allowed_subnets.internet]
    },
    {
      name             = "QUIC",
      protocol         = "udp"
      port_range       = "443"
      source_addresses = [local.allowed_subnets.internet]
    },
    {
      name             = "Tailscale",
      protocol         = "udp"
      port_range       = "41641"
      source_addresses = [local.allowed_subnets.internet]
  }]

  allowed_outbounds = [{
    name             = "All TCP"
    protocol         = "tcp"
    port_range       = "1-65535"
    source_addresses = [local.allowed_subnets.internet]
    },
    {
      name             = "All UDP"
      protocol         = "udp"
      port_range       = "1-65535"
      source_addresses = [local.allowed_subnets.internet]
  }]
}

resource "digitalocean_firewall" "forem" {
  name = resource.digitalocean_droplet.forem.name

  droplet_ids = [resource.digitalocean_droplet.forem.id]

  dynamic "inbound_rule" {
    for_each = { for i, v in local.allowed_inbounds : i => v }

    content {
      protocol         = inbound_rule.value["protocol"]
      port_range       = inbound_rule.value["port_range"]
      source_addresses = inbound_rule.value["source_addresses"]
    }
  }

  dynamic "outbound_rule" {
    for_each = { for i, v in local.allowed_outbounds : i => v }

    content {
      protocol              = outbound_rule.value["protocol"]
      port_range            = outbound_rule.value["port_range"]
      destination_addresses = outbound_rule.value["source_addresses"]
    }
  }
}
