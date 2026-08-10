## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.42.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.data](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/ebs_volume) | resource |
| [aws_eip.static_ip](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/eip) | resource |
| [aws_eip_association.eip_assoc](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/eip_association) | resource |
| [aws_instance.vm](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/instance) | resource |
| [aws_internet_gateway.gateway](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/internet_gateway) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/route_table) | resource |
| [aws_route_table_association.assoc](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/route_table_association) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/security_group) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/subnet) | resource |
| [aws_volume_attachment.data_attach](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/volume_attachment) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/vpc) | resource |
| [random_id.volume_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_ec2_instance_type_offerings.available](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/data-sources/ec2_instance_type_offerings) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Specifies the ID of the custom OS image used to provision all RKE2 cluster EC2 instances. Default is empty. | `string` | `""` | no |
| <a name="input_create_network_resources"></a> [create\_network\_resources](#input\_create\_network\_resources) | Specifies whether to create the VPC networking resources (security group and related resources). Default is 'false'. | `bool` | `false` | no |
| <a name="input_data_disk_count"></a> [data\_disk\_count](#input\_data\_disk\_count) | Specifies the number of additional data disks to attach to each VM instance. Default is 1. | `number` | `1` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of each additional data disks attached to the EC2 instance, in GB. Default is '350'. | `number` | `350` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Specifies the number of EC2 instances to create. Default is 1. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the name of an AWS EC2 instance. Default is 'm8i.large'. | `string` | `"m8i.large"` | no |
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | Specifies the range of private IPs available for the AWS Subnet and VPC. Default is '10.10.0.0'. | `string` | `"10.0.0.0"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'aws-tf'. | `string` | `"aws-tf"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the AWS region used for all resources. Default is 'us-east-1'. | `string` | `"us-east-1"` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Specifies the ID of an existing AWS security group to associate with the EC2 instances. Default is 'null'. | `string` | `null` | no |
| <a name="input_spot_instance"></a> [spot\_instance](#input\_spot\_instance) | Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'. | `bool` | `true` | no |
| <a name="input_ssh_key_content"></a> [ssh\_key\_content](#input\_ssh\_key\_content) | Specifies the public SSH key content used to create the AWS EC2 Key Pair. Default is 'null'. | `string` | `null` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Specifies the name of the AWS EC2 Key Pair used to access the instances through SSH. Default is 'null'. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Specifies the ID of an existing AWS subnet where the EC2 instances will be deployed. Default is 'null'. | `string` | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Specifies cloud-init user\_data used to bootstrap the EC2 instance. Default is 'null'. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_security_group"></a> [aws\_security\_group](#output\_aws\_security\_group) | AWS Security Group. |
| <a name="output_aws_subnet"></a> [aws\_subnet](#output\_aws\_subnet) | AWS Subnet. |
| <a name="output_instances_private_ip"></a> [instances\_private\_ip](#output\_instances\_private\_ip) | AWS EC2 Instance Private IPs. |
| <a name="output_instances_public_ip"></a> [instances\_public\_ip](#output\_instances\_public\_ip) | AWS EC2 Instance Public IPs. |
