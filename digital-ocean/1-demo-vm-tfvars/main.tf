variable "do_token" {}
variable "ssh_keys" {}
variable "region" {}
variable "size" {}
variable "image" {}

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "web" {
  image  = var.image
  name   = "web-1"
  region = var.region
  size   = var.size
  ssh_keys = var.ssh_keys
}

output "ip_address" {
  value = digitalocean_droplet.example.ipv4_address
}

