locals {
  instance_os_type = "opensuse"
  ssh_username     = local.instance_os_type
  public_tcp_ports = ["68", "443", "2112-32767"]
  public_udp_ports = ["68", "443", "2112-32767"]
}

resource "random_id" "volume_suffix" {
  count       = var.data_disk_count * var.instance_count
  byte_length = 2
}

resource "digitalocean_volume" "data_disk" {
  count  = var.data_disk_count * var.instance_count
  name   = "${var.prefix}-data-disk-${count.index + 1}-${random_id.volume_suffix[count.index].hex}"
  size   = var.data_disk_size
  region = var.region
}

resource "digitalocean_volume_attachment" "data_disk_attachment" {
  count      = var.data_disk_count * var.instance_count
  volume_id  = digitalocean_volume.data_disk[count.index].id
  droplet_id = digitalocean_droplet.nodes[floor(count.index / var.data_disk_count)].id
}

resource "digitalocean_droplet" "nodes" {
  count     = var.instance_count
  name      = var.prefix
  tags      = ["user:${var.prefix}"]
  region    = var.region
  size      = var.instance_type
  image     = var.image_id
  ssh_keys  = [var.ssh_key_id]
  user_data = var.user_data

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for startup script to complete...'",
      "while [ ! -f /var/run/startup_script_done ]; do echo 'Startup script is still running, sleeping 3 seconds' && sleep 3; done",
      "echo 'Completed startup script!'"
    ]

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = local.ssh_username
      private_key = var.ssh_private_key_content
    }
  }
}

resource "digitalocean_firewall" "main_firewall" {
  name        = "${var.prefix}-firewall"
  droplet_ids = digitalocean_droplet.nodes[*].id
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.public_ip_source_addresses
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "6080"
    source_addresses = var.public_ip_source_addresses
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "6443"
    source_addresses = concat(var.public_ip_source_addresses, digitalocean_droplet.nodes[*].ipv4_address)
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "9345"
    source_addresses = concat(var.public_ip_source_addresses, digitalocean_droplet.nodes[*].ipv4_address)
  }
  dynamic "inbound_rule" {
    for_each = toset(local.public_tcp_ports)
    content {
      protocol         = "tcp"
      port_range       = inbound_rule.value
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
  dynamic "inbound_rule" {
    for_each = toset(local.public_udp_ports)
    content {
      protocol         = "udp"
      port_range       = inbound_rule.value
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
