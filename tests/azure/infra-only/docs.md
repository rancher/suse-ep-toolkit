## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.79.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.1.0 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | 14.1.0 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.79.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eptoolkit_node"></a> [eptoolkit\_node](#module\_eptoolkit\_node) | ../../../modules/infrastructure/azure/virtual-machine | n/a |
| <a name="module_identity"></a> [identity](#module\_identity) | ../../../modules/identity/ssh/azure | n/a |
| <a name="module_os_image"></a> [os\_image](#module\_os\_image) | ../../../modules/custom-os-image/azure | n/a |
| <a name="module_rke2_first"></a> [rke2\_first](#module\_rke2\_first) | ../../../modules/distribution/rke2 | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/4.79.0/docs/resources/resource_group) | resource |
| [local_file.kubeconfig_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.rke2_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [ssh_resource.retrieve_kubeconfig](https://registry.terraform.io/providers/loafoe/ssh/2.7.0/docs/resources/resource) | resource |
| [ssh_resource.verify_cluster](https://registry.terraform.io/providers/loafoe/ssh/2.7.0/docs/resources/resource) | resource |
| [http_http.my_public_ip_address](https://registry.terraform.io/providers/hashicorp/http/3.5.0/docs/data-sources/http) | data source |
| [local_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the additional data disks for each VM instance, in GB. Default is '500'. | `number` | `40` | no |
| <a name="input_disk_iops_read_write"></a> [disk\_iops\_read\_write](#input\_disk\_iops\_read\_write) | Specifies the amount of disk IOPS on the data disk | `number` | `3000` | no |
| <a name="input_disk_throughput_mbps_read_write"></a> [disk\_throughput\_mbps\_read\_write](#input\_disk\_throughput\_mbps\_read\_write) | Specifies the amount of disk throughput on the data disk | `number` | `125` | no |
| <a name="input_image_offer"></a> [image\_offer](#input\_image\_offer) | Specifies the offer of the Marketplace image used when ami\_id is not provided. Default is 'null'. | `string` | `null` | no |
| <a name="input_image_publisher"></a> [image\_publisher](#input\_image\_publisher) | Specifies the publisher of the Marketplace image used when ami\_id is not provided. Default is 'null'. | `string` | `null` | no |
| <a name="input_image_sku"></a> [image\_sku](#input\_image\_sku) | Specifies the SKU of the Marketplace image used when ami\_id is not provided. Default is 'null'. | `string` | `null` | no |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | Specifies the version of the Marketplace image used when ami\_id is not provided. Default is 'null'. | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the name of an Azure Virtual Machine type. Default is 'Standard\_D8s\_v5'. https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dsv5-series | `string` | `"Standard_D4s_v5"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'azure-tf'. | `string` | `"eptoolkitinfratest"` | no |
| <a name="input_public_ip_source_addresses"></a> [public\_ip\_source\_addresses](#input\_public\_ip\_source\_addresses) | Specifies a list of CIDR blocks allowed to access port 22 (SSH). Default is an empty list (no restrictions defined at variable level). | `list(string)` | `[]` | no |
| <a name="input_rke2_ingress"></a> [rke2\_ingress](#input\_rke2\_ingress) | Specifies the ingress controller to deploy. Allowed values are 'traefik', 'nginx', or 'none'. Default is 'traefik'. | `string` | `"traefik"` | no |
| <a name="input_rke2_version"></a> [rke2\_version](#input\_rke2\_version) | Specifies the RKE2 version to install. Default is 'v1.35.4+rke2r1'. | `string` | `"v1.35.4+rke2r1"` | no |
| <a name="input_spot_instance"></a> [spot\_instance](#input\_spot\_instance) | Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'. | `bool` | `false` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Specifies the Azure Subscription ID that will contain all created resources. Default is empty. | `string` | `""` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Specifies the Azure zone where resources will be allocated. Default is '1'. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_nodes_status"></a> [cluster\_nodes\_status](#output\_cluster\_nodes\_status) | n/a |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | n/a |
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | n/a |
