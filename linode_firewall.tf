resource "linode_firewall" "evilfactorylabs_social" {
  inbound_policy = "ACCEPT"
  label          = linode_instance.evilfactorylabs_social.label
  linodes = [
    linode_instance.evilfactorylabs_social.id,
  ]
  outbound_policy = "ACCEPT"

  inbound {
    action = "ACCEPT"
    ipv4 = [
      "100.64.0.0/10"
    ]
    ipv6     = []
    label    = "accept-inbound-SSH"
    ports    = "22"
    protocol = "TCP"
  }
  inbound {
    action = "DROP"
    ipv4 = [
      "0.0.0.0/0",
    ]
    ipv6 = [
      "::/0",
    ]
    label    = "drop-inbound-SSH"
    ports    = "22"
    protocol = "TCP"
  }
  inbound {
    action = "ACCEPT"
    ipv4 = [
      "0.0.0.0/0",
    ]
    ipv6 = [
      "::/0",
    ]
    label    = "accept-inbound-HTTP"
    ports    = "80"
    protocol = "TCP"
  }
  inbound {
    action = "ACCEPT"
    ipv4 = [
      "0.0.0.0/0",
    ]
    ipv6 = [
      "::/0",
    ]
    label    = "accept-inbound-HTTPS"
    ports    = "443"
    protocol = "TCP"
  }
}
