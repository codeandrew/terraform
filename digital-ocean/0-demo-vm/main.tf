terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

resource "digitalocean_droplet" "example" {
  image  = "ubuntu-20-04-x64"
  name   = "example-droplet"
  region = "nyc1"
  size   = "s-2vcpu-4gb"

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    timeout     = "2m"
    host        = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello, World!' > /root/hello.txt",
    ]
  }
}

output "ip_address" {
  value = digitalocean_droplet.example.ipv4_address
}
