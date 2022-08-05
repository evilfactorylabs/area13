variable "do_token" {
  description = "get it from https://cloud.digitalocean.com/account/api/tokens"
}

variable "dns_authoritaive_nameservers" {
  default = ["ns1.digitalocean.com", "ns2.digitalocean.com", "ns3.digitalocean.com"]
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