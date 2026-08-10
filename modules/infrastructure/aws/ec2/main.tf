locals {
  letters          = ["b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t"]
  instance_os_type = "opensuse"
  ssh_username     = local.instance_os_type
  common_tags = {
    Name       = "${var.prefix}"
    Workload   = "harvester"
    Managed_by = "terraform"
  }
  available_azs = data.aws_ec2_instance_type_offerings.available.locations
  selected_az   = length(local.available_azs) > 0 ? local.available_azs[0] : null
}

resource "random_id" "volume_suffix" {
  count       = var.data_disk_count * var.instance_count
  byte_length = 2
}

resource "aws_vpc" "vpc" {
  count                = var.create_network_resources ? 1 : 0
  cidr_block           = "${var.ip_cidr_range}/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.common_tags
}

resource "aws_subnet" "public" {
  count                   = var.create_network_resources ? 1 : 0
  vpc_id                  = aws_vpc.vpc[0].id
  cidr_block              = "${var.ip_cidr_range}/25"
  map_public_ip_on_launch = true
  availability_zone       = local.available_azs[0]
  tags                    = local.common_tags
  lifecycle {
    precondition {
      condition     = local.selected_az != null
      error_message = "No availability zones available in this region for instance type ${var.instance_type}."
    }
  }
}

resource "aws_internet_gateway" "gateway" {
  count  = var.create_network_resources ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id
  tags   = local.common_tags
}

resource "aws_route_table" "public" {
  count  = var.create_network_resources ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway[0].id
  }
}

resource "aws_route_table_association" "assoc" {
  count          = var.create_network_resources ? 1 : 0
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_security_group" "sg" {
  count  = var.create_network_resources ? 1 : 0
  name   = "${var.prefix}-sg"
  vpc_id = aws_vpc.vpc[0].id
  ingress {
    description = "Allow all intra-cluster traffic between instances in the same security group"
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }
  ingress {
    description = "Allow inbound SSH access restricted to CIDR list"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow inbound Kubernetes API server (6443) access restricted to CIDR list"
    from_port   = "6443"
    to_port     = "6443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow inbound HTTP access restricted to CIDR list"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow public HTTPS inbound access to nodes"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow inbound HTTP access restricted to CIDR list"
    from_port   = "9345"
    to_port     = "9345"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow public HTTPS inbound access to nodes"
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

resource "aws_eip" "static_ip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.vm[0].id
  allocation_id = aws_eip.static_ip.id
}

resource "aws_instance" "vm" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.create_network_resources ? aws_subnet.public[0].id : var.subnet_id
  vpc_security_group_ids      = var.create_network_resources ? [aws_security_group.sg[0].id] : [var.security_group_id]
  associate_public_ip_address = false
  key_name                    = var.ssh_key_name
  user_data                   = var.user_data
  tags                        = local.common_tags
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
    iops        = "3000"
    throughput  = "125"
  }
  instance_market_options {
    market_type = var.spot_instance ? "spot" : null
  }
}

resource "aws_ebs_volume" "data" {
  count             = var.data_disk_count * var.instance_count
  availability_zone = aws_instance.vm[0].availability_zone
  size              = var.data_disk_size
  type              = "gp3"
  iops              = "3000"
  throughput        = "125"
  tags              = local.common_tags
}

resource "aws_volume_attachment" "data_attach" {
  count       = var.data_disk_count * var.instance_count
  device_name = "/dev/sd${local.letters[count.index]}"
  volume_id   = aws_ebs_volume.data[count.index].id
  instance_id = aws_instance.vm[floor(count.index / var.data_disk_count)].id
}
