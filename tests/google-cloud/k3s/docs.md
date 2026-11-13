## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_google"></a> [google](#requirement\_google) | 8.10.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.3.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.6.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.4.0 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | 2.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 8.10.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.6.3 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.9.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_eptoolkit_node"></a> [eptoolkit\_node](#module\_eptoolkit\_node) | ../../../modules/infrastructure/google-cloud/compute-engine | n/a |
| <a name="module_identity"></a> [identity](#module\_identity) | ../../../modules/identity/ssh/google-cloud | n/a |
| <a name="module_k3s_first"></a> [k3s\_first](#module\_k3s\_first) | ../../../modules/distribution/k3s | n/a |
| <a name="module_longhorn"></a> [longhorn](#module\_longhorn) | ../../../modules/distribution/longhorn | n/a |
| <a name="module_os_image"></a> [os\_image](#module\_os\_image) | ../../../modules/custom-os-image/google-cloud | n/a |
| <a name="module_rancher"></a> [rancher](#module\_rancher) | ../../../modules/distribution/rancher | n/a |
| <a name="module_suse_observability"></a> [suse\_observability](#module\_suse\_observability) | ../../../modules/distribution/suse-observability | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [local_file.kubeconfig_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.k3s_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [ssh_resource.retrieve_kubeconfig](https://registry.terraform.io/providers/loafoe/ssh/2.9.0/docs/resources/resource) | resource |
| [ssh_resource.single_node_watchdog](https://registry.terraform.io/providers/loafoe/ssh/2.9.0/docs/resources/resource) | resource |
| [ssh_resource.verify_cluster](https://registry.terraform.io/providers/loafoe/ssh/2.9.0/docs/resources/resource) | resource |
| [ssh_resource.verify_pods](https://registry.terraform.io/providers/loafoe/ssh/2.9.0/docs/resources/resource) | resource |
| [google_compute_image.custom_image](https://registry.terraform.io/providers/hashicorp/google/8.10.0/docs/data-sources/compute_image) | data source |
| [http_http.my_public_ip_address](https://registry.terraform.io/providers/hashicorp/http/3.6.3/docs/data-sources/http) | data source |
| [local_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Specifies the image family, self\_link, or name of the custom OS image. Must start with 'opensuse-leap-16' and end with 'x86-64'. Default is empty. | `string` | `""` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the additional data disks for each VM instance, in GB. Default is '150'. | `number` | `150` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the name of a GCP machine type. Default is 'n2-standard-8'. | `string` | `"n2-standard-8"` | no |
| <a name="input_k3s_ingress"></a> [k3s\_ingress](#input\_k3s\_ingress) | Specifies the ingress controller to deploy. Allowed values are 'traefik', 'nginx', or 'none'. Default is 'traefik'. | `string` | `"traefik"` | no |
| <a name="input_k3s_version"></a> [k3s\_version](#input\_k3s\_version) | Specifies the K3s version to install. Default is 'v1.36.5+k3s1'. | `string` | `"v1.36.5+k3s1"` | no |
| <a name="input_longhorn_admin_password"></a> [longhorn\_admin\_password](#input\_longhorn\_admin\_password) | Specifies the Longhorn administrator password used for securing the Longhorn UI via basic authentication. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is 'null'. | `string` | `null` | no |
| <a name="input_longhorn_enabled"></a> [longhorn\_enabled](#input\_longhorn\_enabled) | Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_longhorn_hc_version"></a> [longhorn\_hc\_version](#input\_longhorn\_hc\_version) | Specifies the Longhorn Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'eptoolkit-k3s-test'. | `string` | `"eptoolkit-k3s-test"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Specifies the GCP Project ID that will contain all created resources. Default is empty. | `string` | `""` | no |
| <a name="input_public_ip_source_addresses"></a> [public\_ip\_source\_addresses](#input\_public\_ip\_source\_addresses) | Specifies a list of CIDR blocks allowed to access port 22 (SSH). Default is an empty list (no restrictions defined at variable level). | `list(string)` | `[]` | no |
| <a name="input_rancher_bootstrap_password"></a> [rancher\_bootstrap\_password](#input\_rancher\_bootstrap\_password) | Specifies the bootstrap administrator password used during Rancher installation. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character when Rancher is enabled. Default is empty. | `string` | `""` | no |
| <a name="input_rancher_enabled"></a> [rancher\_enabled](#input\_rancher\_enabled) | Specifies whether Rancher should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_rancher_hc_version"></a> [rancher\_hc\_version](#input\_rancher\_hc\_version) | Specifies the Rancher Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_suse_observability_admin_password"></a> [suse\_observability\_admin\_password](#input\_suse\_observability\_admin\_password) | Specifies the SUSE Observability administrator password used during installation. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is empty. | `string` | `""` | no |
| <a name="input_suse_observability_enabled"></a> [suse\_observability\_enabled](#input\_suse\_observability\_enabled) | Specifies whether SUSE Observability should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_suse_observability_hc_version"></a> [suse\_observability\_hc\_version](#input\_suse\_observability\_hc\_version) | Specifies the SUSE Observability Helm chart version to install. Default is null (latest version). Default is 'null'. | `string` | `null` | no |
| <a name="input_suse_observability_license"></a> [suse\_observability\_license](#input\_suse\_observability\_license) | Specifies the SUSE Observability license key required for installation. Default is 'null'. | `string` | `""` | no |
| <a name="input_suse_observability_profile"></a> [suse\_observability\_profile](#input\_suse\_observability\_profile) | Specifies the SUSE Observability deployment sizing profile. Supported values depend on the Helm chart configuration. Default is 'trial'. | `string` | `"trial"` | no |
| <a name="input_suse_observability_rancher_auth"></a> [suse\_observability\_rancher\_auth](#input\_suse\_observability\_rancher\_auth) | Specifies whether Rancher should be used as the OIDC provider for SUSE Observability. Default is 'false'. | `bool` | `false` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Specifies the GCP zone letter (e.g., 'a', 'b', 'c') where the instances will be deployed. If null, a zone in the region will be randomly chosen. Default is 'null'. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_node_status"></a> [cluster\_node\_status](#output\_cluster\_node\_status) | n/a |
| <a name="output_cluster_pod_status"></a> [cluster\_pod\_status](#output\_cluster\_pod\_status) | n/a |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | n/a |
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | n/a |
| <a name="output_longhorn_url"></a> [longhorn\_url](#output\_longhorn\_url) | n/a |
| <a name="output_observability_url"></a> [observability\_url](#output\_observability\_url) | n/a |
| <a name="output_rancher_url"></a> [rancher\_url](#output\_rancher\_url) | n/a |
