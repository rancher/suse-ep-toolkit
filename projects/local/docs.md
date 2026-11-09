## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.1.0 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | 14.1.0 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | 2.7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_ai_factory"></a> [ai\_factory](#module\_ai\_factory) | ../../modules/distribution/ai-factory | n/a |
| <a name="module_longhorn"></a> [longhorn](#module\_longhorn) | ../../modules/distribution/longhorn | n/a |
| <a name="module_neuvector"></a> [neuvector](#module\_neuvector) | ../../modules/distribution/neuvector | n/a |
| <a name="module_rancher"></a> [rancher](#module\_rancher) | ../../modules/distribution/rancher | n/a |
| <a name="module_suse_ai"></a> [suse\_ai](#module\_suse\_ai) | ../../modules/distribution/suse-ai | n/a |
| <a name="module_suse_observability"></a> [suse\_observability](#module\_suse\_observability) | ../../modules/distribution/suse-observability | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [local_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ai_factory_enabled"></a> [ai\_factory\_enabled](#input\_ai\_factory\_enabled) | Specifies whether SUSE AI Factory should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_ai_factory_hc_version"></a> [ai\_factory\_hc\_version](#input\_ai\_factory\_hc\_version) | Specifies the SUSE AI Factory Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_app_collection_password"></a> [app\_collection\_password](#input\_app\_collection\_password) | Specifies the SUSE AppCo password. Default is 'null'. | `string` | `null` | no |
| <a name="input_app_collection_username"></a> [app\_collection\_username](#input\_app\_collection\_username) | Specifies the SUSE AppCo username. Default is 'null'. | `string` | `null` | no |
| <a name="input_ingress_ip"></a> [ingress\_ip](#input\_ingress\_ip) | Specifies the IP address used to configure ingress resources on the RKE2/K3s cluster. Default is 'null'. | `string` | `null` | no |
| <a name="input_is_gpu_instance"></a> [is\_gpu\_instance](#input\_is\_gpu\_instance) | Specifies whether the cluster nodes are equipped with GPUs. Default is 'false'. | `bool` | `false` | no |
| <a name="input_kubeconfig_file_path"></a> [kubeconfig\_file\_path](#input\_kubeconfig\_file\_path) | Specifies the file path to the kubeconfig file used to interact with the Kubernetes cluster. Default is 'null'. | `string` | `null` | no |
| <a name="input_longhorn_admin_password"></a> [longhorn\_admin\_password](#input\_longhorn\_admin\_password) | Specifies the Longhorn administrator password used for securing the Longhorn UI via basic authentication. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is 'null'. | `string` | `null` | no |
| <a name="input_longhorn_enabled"></a> [longhorn\_enabled](#input\_longhorn\_enabled) | Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_longhorn_hc_version"></a> [longhorn\_hc\_version](#input\_longhorn\_hc\_version) | Specifies the Longhorn Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_milvus_hc_version"></a> [milvus\_hc\_version](#input\_milvus\_hc\_version) | Specifies the Milvus Helm chart version to install. Default is '4.2.2'. | `string` | `"4.2.2"` | no |
| <a name="input_neuvector_admin_password"></a> [neuvector\_admin\_password](#input\_neuvector\_admin\_password) | Specifies the NeuVector administrator password. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is empty. | `string` | `""` | no |
| <a name="input_neuvector_controller_count"></a> [neuvector\_controller\_count](#input\_neuvector\_controller\_count) | Specifies the number of NeuVector controller replicas to deploy. Default is 'null'. | `number` | `null` | no |
| <a name="input_neuvector_enabled"></a> [neuvector\_enabled](#input\_neuvector\_enabled) | Specifies whether NeuVector should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_neuvector_hc_version"></a> [neuvector\_hc\_version](#input\_neuvector\_hc\_version) | Specifies the NeuVector Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_neuvector_scanner_count"></a> [neuvector\_scanner\_count](#input\_neuvector\_scanner\_count) | Specifies the number of NeuVector scanner replicas to deploy. Default is 'null'. | `number` | `null` | no |
| <a name="input_neuvector_version"></a> [neuvector\_version](#input\_neuvector\_version) | Specifies the NeuVector application version deployed by the Helm chart. Default is empty (chart default version). | `string` | `""` | no |
| <a name="input_node_ips"></a> [node\_ips](#input\_node\_ips) | Specifies a list of node IP addresses used to install Longhorn dependencies via SSH on SUSE Linux distributions. If empty, prerequisites must be pre-installed on the nodes. Default is '[]'. | `list(string)` | `[]` | no |
| <a name="input_nvidia_password"></a> [nvidia\_password](#input\_nvidia\_password) | Specifies the NVIDIA password. Default is 'null'. | `string` | `null` | no |
| <a name="input_ollama_hc_version"></a> [ollama\_hc\_version](#input\_ollama\_hc\_version) | Specifies the Ollama Helm chart version to install. Default is null (latest version). | `string` | `null` | no |
| <a name="input_openwebui_hc_version"></a> [openwebui\_hc\_version](#input\_openwebui\_hc\_version) | Specifies the Open WebUI Helm chart version to install. Default is null (latest version). | `string` | `null` | no |
| <a name="input_rancher_bootstrap_password"></a> [rancher\_bootstrap\_password](#input\_rancher\_bootstrap\_password) | Specifies the bootstrap administrator password used during Rancher installation. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character when Rancher is enabled. Default is empty. | `string` | `""` | no |
| <a name="input_rancher_enabled"></a> [rancher\_enabled](#input\_rancher\_enabled) | Specifies whether Rancher should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_rancher_hc_version"></a> [rancher\_hc\_version](#input\_rancher\_hc\_version) | Specifies the Rancher Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Specifies the file path to the SSH private key used for node authentication. Default is 'null'. | `string` | `null` | no |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | Specifies the SSH username used to access the cluster nodes. Default is 'opensuse'. | `string` | `"opensuse"` | no |
| <a name="input_suse_ai_enabled"></a> [suse\_ai\_enabled](#input\_suse\_ai\_enabled) | Specifies whether SUSE AI stack with GPU should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_suse_ai_gpu"></a> [suse\_ai\_gpu](#input\_suse\_ai\_gpu) | Enable GPU support for SUSE AI. If true, requires a GPU-capable instance\_type. Default is 'false'. | `bool` | `false` | no |
| <a name="input_suse_observability_admin_password"></a> [suse\_observability\_admin\_password](#input\_suse\_observability\_admin\_password) | Specifies the SUSE Observability administrator password used during installation. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is empty. | `string` | `""` | no |
| <a name="input_suse_observability_enabled"></a> [suse\_observability\_enabled](#input\_suse\_observability\_enabled) | Specifies whether SUSE Observability should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_suse_observability_hc_version"></a> [suse\_observability\_hc\_version](#input\_suse\_observability\_hc\_version) | Specifies the SUSE Observability Helm chart version to install. Default is null (latest version). Default is 'null'. | `string` | `null` | no |
| <a name="input_suse_observability_license"></a> [suse\_observability\_license](#input\_suse\_observability\_license) | Specifies the SUSE Observability license key required for installation. Default is 'null'. | `string` | `""` | no |
| <a name="input_suse_observability_profile"></a> [suse\_observability\_profile](#input\_suse\_observability\_profile) | Specifies the SUSE Observability deployment sizing profile. Supported values depend on the Helm chart configuration. Default is 'trial'. | `string` | `"trial"` | no |
| <a name="input_suse_observability_rancher_auth"></a> [suse\_observability\_rancher\_auth](#input\_suse\_observability\_rancher\_auth) | Specifies whether Rancher should be used as the OIDC provider for SUSE Observability. Default is 'false'. | `bool` | `false` | no |
| <a name="input_suse_registry_password"></a> [suse\_registry\_password](#input\_suse\_registry\_password) | Specifies the SUSE registry password. Default is 'null'. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_longhorn_url"></a> [longhorn\_url](#output\_longhorn\_url) | Longhorn web UI URL. |
| <a name="output_neuvector_url"></a> [neuvector\_url](#output\_neuvector\_url) | NeuVector web UI URL. |
| <a name="output_observability_url"></a> [observability\_url](#output\_observability\_url) | SUSE Observability web UI URL. |
| <a name="output_open_webui_url"></a> [open\_webui\_url](#output\_open\_webui\_url) | n/a |
| <a name="output_rancher_url"></a> [rancher\_url](#output\_rancher\_url) | Rancher Dashboard web UI URL. |
