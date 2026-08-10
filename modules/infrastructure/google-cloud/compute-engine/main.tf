locals {
  instance_os_type = "opensuse"
  ssh_username     = local.instance_os_type
  tcp_ports        = ["22", "68", "443", "2379", "2380", "2381", "10010", "2112", "30000-32767", "3260", "5900", "6080", "6443", "6444", "8181", "8443", "8444", "9091", "9099", "9345", "9796", "10245", "10246-10249", "10250", "10251", "10252", "10256", "10257", "10258", "10259"]
  udp_ports        = ["8472", "68"]
  target_zone      = var.zone != null ? var.zone : random_shuffle.random_zone[0].result[0]
  common_labels = {
    name       = var.prefix
    workload   = "harvester"
    managed_by = "terraform"
  }
}

resource "random_string" "random" {
  length  = 4
  lower   = true
  numeric = false
  special = false
  upper   = false
}

data "google_compute_zones" "available" {
  region = var.region
}

resource "random_shuffle" "random_zone" {
  count        = var.zone == null ? 1 : 0
  input        = data.google_compute_zones.available.names
  result_count = 1
}

resource "google_compute_network" "vpc" {
  count                   = var.create_network_resources ? 1 : 0
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  count         = var.create_network_resources ? 1 : 0
  name          = "${var.prefix}-subnet"
  region        = var.region
  network       = google_compute_network.vpc[0].name
  ip_cidr_range = var.ip_cidr_range
}

resource "google_compute_firewall" "allow_inbound" {
  count   = var.create_network_resources ? 1 : 0
  name    = "${var.prefix}-allow-inbound"
  network = google_compute_network.vpc[0].name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = local.tcp_ports
  }
  allow {
    protocol = "udp"
    ports    = local.udp_ports
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "static_ip" {
  count  = var.instance_count
  name   = "${var.prefix}-public-ip-${count.index + 1}"
  region = var.region
}

resource "google_compute_disk" "data_disk" {
  count  = var.data_disk_count * var.instance_count
  name   = "${var.prefix}-data-disk-${count.index + 1}-${random_string.random.result}"
  type   = var.data_disk_type
  size   = var.data_disk_size
  zone   = local.target_zone
  labels = local.common_labels
}

resource "google_compute_instance" "vm" {
  count        = var.instance_count
  name         = "${var.prefix}-vm-${count.index + 1}-${random_string.random.result}"
  machine_type = var.instance_type
  zone         = local.target_zone
  tags         = [var.prefix]
  labels       = local.common_labels
  scheduling {
    preemptible        = var.spot_instance
    provisioning_model = var.spot_instance ? "SPOT" : "STANDARD"
    automatic_restart  = var.spot_instance ? false : true
  }
  boot_disk {
    initialize_params {
      type  = var.os_disk_type
      size  = var.os_disk_size
      image = var.ami_id
    }
  }
  dynamic "attached_disk" {
    for_each = slice(
      google_compute_disk.data_disk,
      count.index * var.data_disk_count,
      (count.index + 1) * var.data_disk_count
    )
    content {
      source = attached_disk.value.self_link
    }
  }
  network_interface {
    network    = var.create_network_resources ? google_compute_network.vpc[0].name : var.vpc_id
    subnetwork = var.create_network_resources ? google_compute_subnetwork.subnet[0].name : var.subnet_id
    access_config {
      nat_ip = google_compute_address.static_ip[count.index].address
    }
  }
  metadata = {
    serial-port-logging-enable = "TRUE"
    serial-port-enable         = "TRUE"
    ssh-keys                   = var.ssh_public_key_content != null ? "${local.ssh_username}:${var.ssh_public_key_content}" : null
    user-data                  = var.user_data
  }
  advanced_machine_features {
    enable_nested_virtualization = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
