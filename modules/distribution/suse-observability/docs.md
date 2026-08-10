## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.suse_observability](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.create_suse_observability_rancher_oidc](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.suse_obs_ca_secret](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.suse_obs_tls_secret](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_cert_request.certs](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.certs](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.certs](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [external_external.suse_observability_oidc_rancher](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to kubeconfig file used by kubectl. Default is 'null'. | `string` | `null` | no |
| <a name="input_rancher_enabled"></a> [rancher\_enabled](#input\_rancher\_enabled) | Specifies whether Rancher should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_rancher_host"></a> [rancher\_host](#input\_rancher\_host) | Specifies the hostname used to expose Rancher via Ingress. Default is 'null'. | `string` | `null` | no |
| <a name="input_suse_observability_admin_password"></a> [suse\_observability\_admin\_password](#input\_suse\_observability\_admin\_password) | Specifies the SUSE Observability administrator password used during installation. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is empty. | `string` | `""` | no |
| <a name="input_suse_observability_enabled"></a> [suse\_observability\_enabled](#input\_suse\_observability\_enabled) | Specifies whether SUSE Observability should be installed on the Kubernetes cluster. Default is 'false'. | `bool` | `false` | no |
| <a name="input_suse_observability_hc_version"></a> [suse\_observability\_hc\_version](#input\_suse\_observability\_hc\_version) | Specifies the SUSE Observability Helm chart version to install. Default is 'null' (latest version). | `string` | `null` | no |
| <a name="input_suse_observability_host"></a> [suse\_observability\_host](#input\_suse\_observability\_host) | Specifies the hostname used to expose SUSE Observability via Ingress (e.g. sslip.io or custom domain). Default is 'null'. | `string` | `null` | no |
| <a name="input_suse_observability_license"></a> [suse\_observability\_license](#input\_suse\_observability\_license) | Specifies the SUSE Observability license key required for installation. Default is 'null'. | `string` | `null` | no |
| <a name="input_suse_observability_otlp_host"></a> [suse\_observability\_otlp\_host](#input\_suse\_observability\_otlp\_host) | Specifies the hostname used to expose SUSE Observability OTLP endpoint via Ingress (e.g. sslip.io or custom domain). Default is 'null'. | `string` | `null` | no |
| <a name="input_suse_observability_otlp_http_host"></a> [suse\_observability\_otlp\_http\_host](#input\_suse\_observability\_otlp\_http\_host) | Specifies the hostname used to expose SUSE Observability OTLP HTTP endpoint via Ingress (e.g. sslip.io or custom domain). Default is 'null'. | `string` | `null` | no |
| <a name="input_suse_observability_profile"></a> [suse\_observability\_profile](#input\_suse\_observability\_profile) | Specifies the SUSE Observability deployment sizing profile. Supported values depend on the Helm chart configuration. Default is 'trial'. | `string` | `"trial"` | no |
| <a name="input_suse_observability_rancher_auth"></a> [suse\_observability\_rancher\_auth](#input\_suse\_observability\_rancher\_auth) | Specifies whether Rancher should be used as the OIDC provider for SUSE Observability. Default is 'false'. | `bool` | `false` | no |

## Outputs

No outputs.
