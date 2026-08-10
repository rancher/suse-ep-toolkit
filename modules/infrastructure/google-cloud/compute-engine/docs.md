## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.static_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.data_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_firewall.allow_inbound](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [random_shuffle.random_zone](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Specifies the image family, self\_link or name of the OS image. Default is empty. | `string` | `""` | no |
| <a name="input_create_network_resources"></a> [create\_network\_resources](#input\_create\_network\_resources) | Specifies whether to create the VPC networking resources (VPC, Subnet, Firewall rules). Default is 'false'. | `bool` | `false` | no |
| <a name="input_data_disk_count"></a> [data\_disk\_count](#input\_data\_disk\_count) | Specifies the number of additional data disks to attach to each VM instance. Default is '1'. | `number` | `1` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the additional data disks for each VM instance, in GB. Default is '350'. | `number` | `350` | no |
| <a name="input_data_disk_type"></a> [data\_disk\_type](#input\_data\_disk\_type) | Specifies the type of the additional data disks ('pd-standard', 'pd-balanced', or 'pd-ssd'). Default is 'pd-ssd'. | `string` | `"pd-ssd"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Specifies the number of GCP Compute Engine instances to create. Default is '1'. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the name of a GCP machine type. Default is 'n2-standard-8'. | `string` | `"n2-standard-8"` | no |
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | Specifies the range of private IPs available for the Subnet and VPC. Default is '10.10.0.0/24'. | `string` | `"10.10.0.0/24"` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Specifies the size of the boot disk attached to each node, in GB. Default is '100'. | `number` | `100` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | Specifies the type of the boot disk ('pd-standard', 'pd-balanced', or 'pd-ssd'). Default is 'pd-ssd'. | `string` | `"pd-ssd"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'gcp-tf'. | `string` | `"gcp-tf"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the GCP region used for all resources. Default is 'europe-west1'. | `string` | `"europe-west1"` | no |
| <a name="input_spot_instance"></a> [spot\_instance](#input\_spot\_instance) | Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'. | `bool` | `true` | no |
| <a name="input_ssh_public_key_content"></a> [ssh\_public\_key\_content](#input\_ssh\_public\_key\_content) | Specifies the public SSH key content. Default is 'null'. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Specifies the name or self\_link of an existing GCP Subnet where the instances will be deployed. Default is 'null'. | `string` | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Specifies cloud-init user\_data used to bootstrap the GCP Compute Instance. Default is 'null'. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Specifies the name or self\_link of an existing VPC network. Default is 'null'. | `string` | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Specifies the GCP zone where the instances will be deployed. If null, a zone in the region will be randomly chosen. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_subnet"></a> [gcp\_subnet](#output\_gcp\_subnet) | GCP Subnet ID/Name. |
| <a name="output_gcp_vpc"></a> [gcp\_vpc](#output\_gcp\_vpc) | GCP VPC Network ID/Name. |
| <a name="output_instances_private_ip"></a> [instances\_private\_ip](#output\_instances\_private\_ip) | GCP Compute Engine Instance Private IPs. |
| <a name="output_instances_public_ip"></a> [instances\_public\_ip](#output\_instances\_public\_ip) | GCP Compute Engine Instance Public IPs. |
