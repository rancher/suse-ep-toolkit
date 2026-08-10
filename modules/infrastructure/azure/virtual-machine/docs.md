## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.79.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.79.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.data_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.nsg_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.allow_inbound](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.allow_outbound](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.vm_ip](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/public_ip) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/subnet) | resource |
| [azurerm_virtual_machine_data_disk_attachment.data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/virtual_network) | resource |
| [random_id.volume_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Specifies the ID of the custom OS image used to provision all RKE2 cluster Azure Virtual Machines. Default is empty. | `string` | `""` | no |
| <a name="input_create_network_resources"></a> [create\_network\_resources](#input\_create\_network\_resources) | Specifies whether to create the VNet networking resources (security group and related resources). Default is 'false'. | `bool` | `false` | no |
| <a name="input_data_disk_count"></a> [data\_disk\_count](#input\_data\_disk\_count) | Specifies the number of additional data disks to attach to each VM instance. Default is '1'. | `number` | `1` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the additional data disks for each VM instance, in GB. Default is '350'. | `number` | `350` | no |
| <a name="input_data_disk_type"></a> [data\_disk\_type](#input\_data\_disk\_type) | Specifies the type of the disks attached to each node ('Standard\_LRS, 'StandardSSD\_LRS', 'Premium\_LRS' or 'UltraSSD\_LRS'). Default is 'Premium\_LRS'. | `string` | `"Premium_LRS"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Specifies the number of Azure Virtual Machines to create. Default is '1'. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the name of an Azure Virtual Machine type. Default is 'Standard\_D8s\_v5'. https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dsv5-series | `string` | `"Standard_D8s_v5"` | no |
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | Specifies the range of private IPs available for the Azure Subnet and VNet. Default is '10.10.0.0'. | `string` | `"10.10.0.0/24"` | no |
| <a name="input_nsg_id"></a> [nsg\_id](#input\_nsg\_id) | Specifies the ID of an existing Azure Network Security Group where the Virtual Machines instances will be deployed. Default is 'null'. | `string` | `null` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Specifies the size of the disk attached to each node, in GB. Default is '100'. | `string` | `"100"` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | Specifies the type of the disk attached to each node ('Standard\_LRS, 'StandardSSD\_LRS', 'Premium\_LRS' or 'UltraSSD\_LRS'). Default is 'StandardSSD\_LRS'. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'azure-tf'. | `string` | `"azure-tf"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the Azure region used for all resources. Default is 'westeurope'. | `string` | `"westeurope"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Specifies the resource group where resources will be allocated. Default is 'null'. | <pre>object({<br>    name     = string<br>    location = string<br>  })</pre> | `null` | no |
| <a name="input_spot_instance"></a> [spot\_instance](#input\_spot\_instance) | Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'. | `bool` | `true` | no |
| <a name="input_ssh_public_key_content"></a> [ssh\_public\_key\_content](#input\_ssh\_public\_key\_content) | Specifies the public SSH key content. Default is 'null'. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Specifies the ID of an existing Azure subnet where the Virtual Machines instances will be deployed. Default is 'null'. | `string` | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Specifies cloud-init user\_data used to bootstrap the Azure Virtual Machine. Default is 'null'. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_nsg"></a> [azure\_nsg](#output\_azure\_nsg) | Azure Network Security Group. |
| <a name="output_azure_subnet"></a> [azure\_subnet](#output\_azure\_subnet) | Azure Subnet. |
| <a name="output_instances_private_ip"></a> [instances\_private\_ip](#output\_instances\_private\_ip) | Azure Virtual Machine Private IPs. |
| <a name="output_instances_public_ip"></a> [instances\_public\_ip](#output\_instances\_public\_ip) | Azure Virtual Machine Instance Public IPs. |
