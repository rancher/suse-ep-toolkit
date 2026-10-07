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
| [helm_release.milvus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.ollama](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.open_webui](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.appco_credentials_and_longhorn_storageclass](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.gpu_operator](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.openwebui_tls_secret](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_cert_request.openwebui](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.openwebui](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.openwebui](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_collection_password"></a> [app\_collection\_password](#input\_app\_collection\_password) | Specifies the SUSE AppCo password. Default is 'null'. | `string` | `null` | no |
| <a name="input_app_collection_username"></a> [app\_collection\_username](#input\_app\_collection\_username) | Specifies the SUSE AppCo username. Default is 'null'. | `string` | `null` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to kubeconfig file used by kubectl. Default is 'null'. | `string` | `null` | no |
| <a name="input_milvus_hc_version"></a> [milvus\_hc\_version](#input\_milvus\_hc\_version) | Specifies the milvus Helm chart version to install. Default is null (latest version). | `string` | `"4.2.2"` | no |
| <a name="input_node_ips"></a> [node\_ips](#input\_node\_ips) | Specifies the list of node public IP addresses used to prepare Longhorn dependencies on each cluster node. Default is 'null'. | `list(string)` | `[]` | no |
| <a name="input_ollama_hc_version"></a> [ollama\_hc\_version](#input\_ollama\_hc\_version) | Specifies the ollama Helm chart version to install. Default is null (latest version). | `string` | `null` | no |
| <a name="input_openwebui_hc_version"></a> [openwebui\_hc\_version](#input\_openwebui\_hc\_version) | Specifies the ollama Helm chart version to install. Default is null (latest version). | `string` | `null` | no |
| <a name="input_openwebui_host"></a> [openwebui\_host](#input\_openwebui\_host) | Specifies the hostname used to expose OpenWebUI via Ingress (e.g. sslip.io or custom domain). Default is 'null'. | `string` | `null` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Specifies the SSH private key content used to connect to cluster nodes for Longhorn dependency preparation. Default is 'true'. | `string` | n/a | yes |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | Specifies the SSH username used to connect to cluster nodes. Default is 'opensuse'. | `string` | `"opensuse"` | no |
| <a name="input_suse_ai_enabled"></a> [suse\_ai\_enabled](#input\_suse\_ai\_enabled) | Specifies whether suse ai stack with gpu should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_suse_ai_gpu"></a> [suse\_ai\_gpu](#input\_suse\_ai\_gpu) | Enable GPU support for SUSE AI. If true, requires a GPU-capable instance\_type. Default is 'false' | `bool` | `false` | no |

## Outputs

No outputs.
