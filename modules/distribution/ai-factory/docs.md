## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.ai_factory](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ai_factory_enabled"></a> [ai\_factory\_enabled](#input\_ai\_factory\_enabled) | Specifies whether Rancher should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_ai_factory_hc_version"></a> [ai\_factory\_hc\_version](#input\_ai\_factory\_hc\_version) | Specifies the Rancher Helm chart version to install. Default is null (latest version). Default is 'null'. | `string` | `null` | no |
| <a name="input_app_collection_password"></a> [app\_collection\_password](#input\_app\_collection\_password) | Specifies the SUSE AppCo password. Default is 'null'. | `string` | `null` | no |
| <a name="input_app_collection_username"></a> [app\_collection\_username](#input\_app\_collection\_username) | Specifies the SUSE AppCo username. Default is 'null'. | `string` | `null` | no |
| <a name="input_nvidia_password"></a> [nvidia\_password](#input\_nvidia\_password) | Specifies the NVIDIA password. Default is 'null'. | `string` | `null` | no |
| <a name="input_suse_registry_password"></a> [suse\_registry\_password](#input\_suse\_registry\_password) | Specifies the SUSE registry password. Default is 'null'. | `string` | `null` | no |

## Outputs

No outputs.
