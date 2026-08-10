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
| [helm_release.longhorn](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.longhorn_auth](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.longhorn_dependencies](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.longhorn_tls_secret](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_cert_request.longhorn](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.longhorn](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.longhorn](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to kubeconfig file used by kubectl. Default is 'null'. | `string` | `null` | no |
| <a name="input_longhorn_admin_password"></a> [longhorn\_admin\_password](#input\_longhorn\_admin\_password) | Specifies the Longhorn administrator password used for securing the Longhorn UI via basic authentication. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is 'null'. | `string` | `null` | no |
| <a name="input_longhorn_enabled"></a> [longhorn\_enabled](#input\_longhorn\_enabled) | Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_longhorn_hc_version"></a> [longhorn\_hc\_version](#input\_longhorn\_hc\_version) | Specifies the Longhorn Helm chart version to install. Default is null (latest version). Default is 'null'. | `string` | `null` | no |
| <a name="input_longhorn_host"></a> [longhorn\_host](#input\_longhorn\_host) | Specifies the hostname used to expose Longhorn via Ingress (e.g. sslip.io or custom domain). Default is 'null'. | `string` | `null` | no |
| <a name="input_node_ips"></a> [node\_ips](#input\_node\_ips) | Specifies the list of node public IP addresses used to prepare Longhorn dependencies on each cluster node. Default is 'null'. | `list(string)` | `[]` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Specifies the SSH private key content used to connect to cluster nodes for Longhorn dependency preparation. Default is 'true'. | `string` | n/a | yes |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | Specifies the SSH username used to connect to cluster nodes. Default is 'opensuse'. | `string` | `"opensuse"` | no |

## Outputs

No outputs.
