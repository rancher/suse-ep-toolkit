## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.neuvector](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.neuvector_tls_secret](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.neuvector_traefik_transport](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_cert_request.neuvector](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.neuvector](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.neuvector](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to kubeconfig file used by kubectl. Default is 'null'. | `string` | `null` | no |
| <a name="input_longhorn_enabled"></a> [longhorn\_enabled](#input\_longhorn\_enabled) | Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_neuvector_admin_password"></a> [neuvector\_admin\_password](#input\_neuvector\_admin\_password) | Specifies the NeuVector administrator password. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is empty. | `string` | `""` | no |
| <a name="input_neuvector_controller_count"></a> [neuvector\_controller\_count](#input\_neuvector\_controller\_count) | Specifies the number of NeuVector controller replicas to deploy. Default is 'null'. | `number` | `null` | no |
| <a name="input_neuvector_enabled"></a> [neuvector\_enabled](#input\_neuvector\_enabled) | Specifies whether NeuVector should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_neuvector_hc_version"></a> [neuvector\_hc\_version](#input\_neuvector\_hc\_version) | Specifies the NeuVector Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_neuvector_host"></a> [neuvector\_host](#input\_neuvector\_host) | Specifies the hostname used to expose NeuVector via Ingress (e.g. sslip.io or custom domain). Default is 'null'. | `string` | `null` | no |
| <a name="input_neuvector_scanner_count"></a> [neuvector\_scanner\_count](#input\_neuvector\_scanner\_count) | Specifies the number of NeuVector scanner replicas to deploy. Default is 'null'. | `number` | `null` | no |
| <a name="input_neuvector_version"></a> [neuvector\_version](#input\_neuvector\_version) | Specifies the NeuVector application version deployed by the Helm chart. Default is empty (chart default version). | `string` | `""` | no |
| <a name="input_rancher_enabled"></a> [rancher\_enabled](#input\_rancher\_enabled) | Specifies whether Rancher should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_rancher_host"></a> [rancher\_host](#input\_rancher\_host) | Specifies the hostname used to expose Rancher via Ingress. Default is 'null'. | `string` | `null` | no |

## Outputs

No outputs.
