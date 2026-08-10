## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.42.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ami.opensuse_ami](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/ami) | resource |
| [aws_ebs_snapshot_import.opensuse_snapshot](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/ebs_snapshot_import) | resource |
| [aws_iam_role.vmimport](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vmimport](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.images](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/s3_bucket) | resource |
| [aws_s3_object.vhd](https://registry.terraform.io/providers/hashicorp/aws/6.42.0/docs/resources/s3_object) | resource |
| [null_resource.download_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.removing_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'aws-tf'. | `string` | `"aws-tf"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_id"></a> [image\_id](#output\_image\_id) | The ID of the custom OS image used for all RKE2 cluster EC2 instances. |
