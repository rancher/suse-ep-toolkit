## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.79.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.79.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_image.harvester](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/image) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/resource_group) | resource |
| [azurerm_storage_account.vhd](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/storage_account) | resource |
| [azurerm_storage_blob.ep_toolkit_vhd](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/storage_blob) | resource |
| [azurerm_storage_container.vhds](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/storage_container) | resource |
| [null_resource.download_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.removing_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait_blob_accessible](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'azure-tf'. | `string` | `"azure-tf"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the Azure region used for all resources. Default is 'westeurope'. | `string` | `"westeurope"` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Specifies the Azure Subscription ID that will contain all created resources. Default is empty. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_id"></a> [image\_id](#output\_image\_id) | The ID of the custom OS image used for all RKE2 cluster EC2 instances. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | Resource Group created on the Azure account. |
