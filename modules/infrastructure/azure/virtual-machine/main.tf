locals {
  instance_os_type = "opensuse"
  ssh_username     = local.instance_os_type
  inbound_ports    = ["22", "68", "443", "2379", "2380", "2381", "10010", "2112", "30000-32767", "3260", "5900", "6080", "6443", "6444", "8181", "8443", "8444", "8472", "9091", "9099", "9345", "9796", "10245", "10246-10249", "10250", "10251", "10252", "10256", "10257", "10258", "10259"]
  common_tags = {
    Name       = "${var.prefix}"
    Workload   = "harvester"
    Managed_by = "terraform"
  }
}

resource "random_string" "random" {
  length  = 4
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "random_id" "volume_suffix" {
  count       = var.data_disk_count * var.instance_count
  byte_length = 2
}

resource "azurerm_virtual_network" "vnet" {
  count               = var.create_network_resources ? 1 : 0
  name                = "${var.prefix}-vnet"
  address_space       = [var.ip_cidr_range]
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "subnet" {
  count                = var.create_network_resources ? 1 : 0
  name                 = "${var.prefix}-subnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.ip_cidr_range]
}

resource "azurerm_public_ip" "vm_ip" {
  name                = "${var.prefix}-public-ip"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  tags                = local.common_tags
}

resource "azurerm_network_security_group" "nsg" {
  count               = var.create_network_resources ? 1 : 0
  name                = "${var.prefix}-nsg"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = local.common_tags
}

resource "azurerm_network_security_rule" "allow_inbound" {
  for_each                    = var.create_network_resources ? toset(local.inbound_ports) : []
  name                        = "${var.prefix}-allow-inbound-${each.key}"
  priority                    = 100 + index(local.inbound_ports, each.key)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = each.key
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg[0].name
}

resource "azurerm_network_security_rule" "allow_outbound" {
  count                       = var.create_network_resources ? 1 : 0
  name                        = "${var.prefix}-allow-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg[0].name
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.create_network_resources ? azurerm_subnet.subnet[0].id : var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_ip.id
  }
  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.create_network_resources ? azurerm_network_security_group.nsg[0].id : var.nsg_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.instance_count
  name                = "${var.prefix}-vm"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  size                = var.instance_type
  admin_username      = local.ssh_username
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]
  priority        = var.spot_instance ? "Spot" : "Regular"
  eviction_policy = var.spot_instance ? "Deallocate" : null
  admin_ssh_key {
    username   = local.ssh_username
    public_key = var.ssh_public_key_content
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size
  }
  source_image_id = var.ami_id
  custom_data     = base64encode(var.user_data)
  tags            = local.common_tags
}

resource "azurerm_managed_disk" "data_disk" {
  count                = var.data_disk_count
  name                 = "${var.prefix}-data-disk-${count.index + 1}"
  location             = var.resource_group.location
  resource_group_name  = var.resource_group.name
  storage_account_type = var.data_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size
  tags                 = local.common_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  count              = var.data_disk_count
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[floor(count.index / var.data_disk_count)].id
  lun                = count.index
  caching            = "ReadWrite"
}
