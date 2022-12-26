variable "do_token" {
  description = "get it from https://cloud.digitalocean.com/account/api/tokens"
}

variable "linode_token" {
  description = "get it from https://cloud.linode.com/profile/tokens"
}

variable "dns_authoritative_nameservers" {
  default = ["ns1.digitalocean.com", "ns2.digitalocean.com", "ns3.digitalocean.com"]
}

variable "dns_authoritative_nameservers_secondary" {
  default = ["ns1.linode.com", "ns2.linode.com", "ns3.linode.com", "ns4.linode.com", "ns5.linode.com"]
}

variable "namecheap_username" {
  type = string
}

variable "namecheap_api_user" {
  type = string
}

variable "namecheap_api_key" {
  description = "get it from https://ap.www.namecheap.com/settings/tools/apiaccess"
}
