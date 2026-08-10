## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 7.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.30.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_image.upload_certified_image](https://registry.terraform.io/providers/hashicorp/google/7.30.0/docs/resources/compute_image) | resource |
| [google_storage_bucket.images_bucket](https://registry.terraform.io/providers/hashicorp/google/7.30.0/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.certified_image](https://registry.terraform.io/providers/hashicorp/google/7.30.0/docs/resources/storage_bucket_object) | resource |
| [null_resource.cleanup_certified_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.download_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'gcp-tf'. | `string` | `"gcp-tf"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Specifies the GCP Project ID that will contain all created resources. Default is empty. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the GCP region used for all resources. Default is 'europe-west1'. | `string` | `"europe-west1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_id"></a> [image\_id](#output\_image\_id) | The self\_link / ID of the custom OS image created on Google Cloud. |
