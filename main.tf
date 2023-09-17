terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
  }

  cloud {
    organization = "evilfactorylabs"
    workspaces {
      name = "area13"
    }
  }
}

provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.do_spaces_access_id
  spaces_secret_key = var.do_spaces_secret_key
}



provider "namecheap" {
  user_name = var.namecheap_username
  api_user  = var.namecheap_api_user
  api_key   = var.namecheap_api_key
}
