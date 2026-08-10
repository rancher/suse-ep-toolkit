## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | 2.85.1 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.1.0 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | 14.1.0 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_identity"></a> [identity](#module\_identity) | ../../../modules/identity/ssh/digitalocean | n/a |
| <a name="module_k3s_additional_servers"></a> [k3s\_additional\_servers](#module\_k3s\_additional\_servers) | ../../../modules/distribution/k3s | n/a |
| <a name="module_k3s_additional_workers"></a> [k3s\_additional\_workers](#module\_k3s\_additional\_workers) | ../../../modules/distribution/k3s | n/a |
| <a name="module_k3s_first"></a> [k3s\_first](#module\_k3s\_first) | ../../../modules/distribution/k3s | n/a |
| <a name="module_k3s_first_server"></a> [k3s\_first\_server](#module\_k3s\_first\_server) | ../../../modules/infrastructure/digitalocean/droplet | n/a |
| <a name="module_k3s_servers"></a> [k3s\_servers](#module\_k3s\_servers) | ../../../modules/infrastructure/digitalocean/droplet | n/a |
| <a name="module_k3s_workers"></a> [k3s\_workers](#module\_k3s\_workers) | ../../../modules/infrastructure/digitalocean/droplet | n/a |
| <a name="module_longhorn"></a> [longhorn](#module\_longhorn) | ../../../modules/distribution/longhorn | n/a |
| <a name="module_neuvector"></a> [neuvector](#module\_neuvector) | ../../../modules/distribution/neuvector | n/a |
| <a name="module_os_image"></a> [os\_image](#module\_os\_image) | ../../../modules/custom-os-image/digitalocean | n/a |
| <a name="module_rancher"></a> [rancher](#module\_rancher) | ../../../modules/distribution/rancher | n/a |
| <a name="module_suse_observability"></a> [suse\_observability](#module\_suse\_observability) | ../../../modules/distribution/suse-observability | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.kubeconfig_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.k3s_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [ssh_resource.retrieve_kubeconfig](https://registry.terraform.io/providers/loafoe/ssh/2.7.0/docs/resources/resource) | resource |
| [local_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the additional data disks attached to the Droplet, in GB. Default is '350'. | `number` | `350` | no |
| <a name="input_disable_components"></a> [disable\_components](#input\_disable\_components) | Specifies bundled K3s components to disable. Default is empty. | `list(string)` | `[]` | no |
| <a name="input_do_ssh_key_id"></a> [do\_ssh\_key\_id](#input\_do\_ssh\_key\_id) | Existing SSH key ID to use. If null, module will use or create one. Default is 'null'. | `string` | `null` | no |
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | DigitalOcean API token used to deploy the infrastructure. Default is 'null'. | `string` | `null` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Specifies the ID of the custom OS image used to provision all K3s cluster droplets. Default is empty. | `string` | `""` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Specifies the number of Droplets (nodes) to create for the K3s cluster. This value defines the total cluster size, including the first server node, additional server nodes (if count <= 3), and worker nodes (if count > 3). Default is '1'. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the name of the DigitalOcean Droplet type. Default is 'g-16vcpu-64gb'. | `string` | `"g-16vcpu-64gb"` | no |
| <a name="input_k3s_config"></a> [k3s\_config](#input\_k3s\_config) | Specifies additional custom K3s configuration in YAML format. Default is empty. | `string` | `""` | no |
| <a name="input_k3s_token"></a> [k3s\_token](#input\_k3s\_token) | Specifies the shared token used by all nodes to join the K3s cluster. Default is 'null'. | `string` | `null` | no |
| <a name="input_k3s_version"></a> [k3s\_version](#input\_k3s\_version) | Specifies the K3s version to install. Default is 'v1.33.5+k3s1'. | `string` | `"v1.33.5+k3s1"` | no |
| <a name="input_longhorn_admin_password"></a> [longhorn\_admin\_password](#input\_longhorn\_admin\_password) | Specifies the Longhorn administrator password used for securing the Longhorn UI via basic authentication. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is 'null'. | `string` | `null` | no |
| <a name="input_longhorn_enabled"></a> [longhorn\_enabled](#input\_longhorn\_enabled) | Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_longhorn_hc_version"></a> [longhorn\_hc\_version](#input\_longhorn\_hc\_version) | Specifies the Longhorn Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_neuvector_admin_password"></a> [neuvector\_admin\_password](#input\_neuvector\_admin\_password) | Specifies the NeuVector administrator password. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is empty. | `string` | `""` | no |
| <a name="input_neuvector_controller_count"></a> [neuvector\_controller\_count](#input\_neuvector\_controller\_count) | Specifies the number of NeuVector controller replicas to deploy. Default is 'null'. | `number` | `null` | no |
| <a name="input_neuvector_enabled"></a> [neuvector\_enabled](#input\_neuvector\_enabled) | Specifies whether NeuVector should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_neuvector_hc_version"></a> [neuvector\_hc\_version](#input\_neuvector\_hc\_version) | Specifies the NeuVector Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_neuvector_scanner_count"></a> [neuvector\_scanner\_count](#input\_neuvector\_scanner\_count) | Specifies the number of NeuVector scanner replicas to deploy. Default is 'null'. | `number` | `null` | no |
| <a name="input_neuvector_version"></a> [neuvector\_version](#input\_neuvector\_version) | Specifies the NeuVector application version deployed by the Helm chart. Default is empty (chart default version). | `string` | `""` | no |
| <a name="input_node_role"></a> [node\_role](#input\_node\_role) | Specifies the K3s node role for this instance. Valid values are 'server' or 'agent'. The role determines whether the node participates in the control plane cluster ('server') or joins as a worker node ('agent'). Default is 'agent'. | `string` | `"agent"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'do-tf'. | `string` | `"do-tf"` | no |
| <a name="input_rancher_bootstrap_password"></a> [rancher\_bootstrap\_password](#input\_rancher\_bootstrap\_password) | Specifies the bootstrap administrator password used during Rancher installation. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character when Rancher is enabled. Default is empty. | `string` | `""` | no |
| <a name="input_rancher_enabled"></a> [rancher\_enabled](#input\_rancher\_enabled) | Specifies whether Rancher should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_rancher_hc_version"></a> [rancher\_hc\_version](#input\_rancher\_hc\_version) | Specifies the Rancher Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_rancher_tls_source"></a> [rancher\_tls\_source](#input\_rancher\_tls\_source) | Specifies the TLS certificate source used by Rancher. Default is 'letsEncrypt'. | `string` | `"letsEncrypt"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the DigitalOcean region used for all resources. Default is 'fra1'. | `string` | `"fra1"` | no |
| <a name="input_server_url"></a> [server\_url](#input\_server\_url) | Specifies the URL of the first K3s server node (required for 'server' joining an existing cluster and for 'agent'). Default is 'null'. | `string` | `null` | no |
| <a name="input_suse_observability_admin_password"></a> [suse\_observability\_admin\_password](#input\_suse\_observability\_admin\_password) | Specifies the SUSE Observability administrator password used during installation. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is empty. | `string` | `""` | no |
| <a name="input_suse_observability_enabled"></a> [suse\_observability\_enabled](#input\_suse\_observability\_enabled) | Specifies whether SUSE Observability should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_suse_observability_hc_version"></a> [suse\_observability\_hc\_version](#input\_suse\_observability\_hc\_version) | Specifies the SUSE Observability Helm chart version to install. Default is null (latest version). Default is 'null'. | `string` | `null` | no |
| <a name="input_suse_observability_license"></a> [suse\_observability\_license](#input\_suse\_observability\_license) | Specifies the SUSE Observability license key required for installation. Default is 'null'. | `string` | `""` | no |
| <a name="input_suse_observability_profile"></a> [suse\_observability\_profile](#input\_suse\_observability\_profile) | Specifies the SUSE Observability deployment sizing profile. Supported values depend on the Helm chart configuration. Default is 'trial'. | `string` | `"trial"` | no |
| <a name="input_suse_observability_rancher_auth"></a> [suse\_observability\_rancher\_auth](#input\_suse\_observability\_rancher\_auth) | Specifies whether Rancher should be used as the OIDC provider for SUSE Observability. Default is 'false'. | `bool` | `false` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Specifies cloud-init user\_data used to bootstrap the Droplet. Default is 'null'. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_first_server_public_ip"></a> [first\_server\_public\_ip](#output\_first\_server\_public\_ip) | n/a |
| <a name="output_longhorn_url"></a> [longhorn\_url](#output\_longhorn\_url) | n/a |
| <a name="output_neuvector_url"></a> [neuvector\_url](#output\_neuvector\_url) | n/a |
| <a name="output_observability_url"></a> [observability\_url](#output\_observability\_url) | n/a |
| <a name="output_rancher_url"></a> [rancher\_url](#output\_rancher\_url) | n/a |
| <a name="output_server_nodes_public_ip"></a> [server\_nodes\_public\_ip](#output\_server\_nodes\_public\_ip) | n/a |
| <a name="output_worker_nodes_public_ip"></a> [worker\_nodes\_public\_ip](#output\_worker\_nodes\_public\_ip) | n/a |
