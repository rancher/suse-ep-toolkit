# Google Cloud Compute Engine VM K3s Project

This project can deploy and configure the following:

- Longhorn
- Rancher
- NeuVector
- SUSE Observability
- SUSE AI Factory
- SUSE AI

All components are deployed automatically using reusable modules from the repository.

# How to create resources

- Copy `./terraform.tfvars.example` to `./terraform.tfvars`
- Edit `./terraform.tfvars`
Example:

```bash
cp terraform.tfvars.example terraform.tfvars
```
- Please make sure that nodes contain require packages for Longhorn or configure variable `node_ips` with the list of IPs from the nodes whether OpenSUSE or SLEs is the Operating system as well as `ssh_username` and `ssh_private_key_path` for automatic longhorn packages installation.
- Please note that SUSE AI with GPU requires NVIDIA drivers to be installed on the nodes. Project won't install those packages automatically.
- Please make sure to define `ingress_ip` variable with the IP used when creating ingresses for applications.


# Component relationships and requirements

Some components depend on others and cannot be enabled independently.

## Longhorn

Longhorn requires:

- `longhorn_admin_password`

Example:

```hcl
longhorn_enabled        = true
longhorn_admin_password = "************"
```

## Rancher

Rancher requires:

- `longhorn_enabled = true`
- `rancher_bootstrap_password`

Example:

```hcl
longhorn_enabled           = true

rancher_enabled            = true
rancher_bootstrap_password = "************"
```

## SUSE Observability

SUSE Observability requires:

- `longhorn_enabled = true`
- `instance_count >= 3`
- `suse_observability_license`
- `suse_observability_admin_password`

Example:

```hcl
longhorn_enabled                  = true

suse_observability_enabled        = true
suse_observability_license        = "<LICENSE>"
suse_observability_admin_password = "************"
```

If Rancher is enabled and you want to take advantage of Single sign-on login:

- `rancher_enabled = true`
- `suse_observability_rancher_auth = true`

Example:

```hcl
longhorn_enabled                = true

rancher_enabled                 = true

suse_observability_enabled      = true
suse_observability_license      = "<LICENSE>"
suse_observability_rancher_auth = true
```

## NeuVector

NeuVector can be enabled independently.

If Rancher is enabled, NeuVector automatically configures Rancher SSO integration.

Example:

```hcl
neuvector_enabled        = true
neuvector_admin_password = "************"
```

## SUSE AI Factory

SUSE AI Factory requires:

```hcl
longhorn_enabled           = true
longhorn_admin_password    = "************"

rancher_enabled            = true
rancher_bootstrap_password = "************"

ai_factory_enabled         = true
app_collection_username    = "************"
app_collection_password    = "************"
nvidia_password            = "************"
suse_registry_password     = "************"
```

## SUSE AI with GPUs

To deploy SUSE AI, you must configure gpu_type and gpu_count variables for better formance.

Example:

```hcl
longhorn_enabled           = true
longhorn_admin_password    = "************"

rancher_enabled            = true
rancher_bootstrap_password = "************"

suse_ai_enabled            = true
is_gpu_instance            = true

app_collection_username    = "************"
app_collection_password    = "************"
```

## SUSE AI without GPUs (CPU-only)

To deploy SUSE AI without GPUs.

Example:

```hcl
longhorn_enabled           = true
longhorn_admin_password    = "************"

rancher_enabled            = true
rancher_bootstrap_password = "************"

suse_ai_enabled            = true

app_collection_username    = "************"
app_collection_password    = "************"
```

Note: Performance will be reduced.

## Full stack deployment

```hcl
longhorn_enabled                = true
longhorn_admin_password         = "************"

rancher_enabled                 = true
rancher_bootstrap_password      = "************"

neuvector_enabled               = true
neuvector_admin_password        = "************"

suse_observability_enabled      = true
suse_observability_license      = "<LICENSE>"
suse_observability_rancher_auth = true

ai_factory_enabled              = true
nvidia_password                 = "************"
suse_registry_password          = "************"

suse_ai_enabled                 = true

app_collection_username         = "************"
app_collection_password         = "************"
```

# Terraform Apply

```bash
terraform init -upgrade
terraform apply -auto-approve
```

# Terraform Destroy

```bash
terraform destroy -auto-approve
```

# OpenTofu Apply

```bash
tofu init -upgrade
tofu apply -auto-approve
```

# OpenTofu Destroy

```bash
tofu destroy -auto-approve
```

# Exposed services

Depending on enabled components, the following services become available:

| Component | URL |
|---|---|
| Rancher | `https://rancher.<NODE_IP>.sslip.io` |
| Longhorn | `https://longhorn.<NODE_IP>.sslip.io` |
| NeuVector | `https://neuvector.<NODE_IP>.sslip.io` |
| SUSE Observability | `https://observability.<NODE_IP>.sslip.io` |
| OpenTelemetry (OTLP/gRPC) | `https://otlp-observability.<NODE_IP>.sslip.io` |
| OpenTelemetry (OTLP/HTTP) | `https://otlp-http-observability.<NODE_IP>.sslip.io` |
| OpenWebUI | `https://openwebui.<NODE_IP>.sslip.io` |

# Notes

- TLS certificates are automatically generated
- Longhorn UI is protected with Traefik Basic Authentication
- NeuVector automatically integrates with Rancher SSO when Rancher is enabled
- SUSE Observability supports Rancher OIDC authentication, which can be enabled by setting `suse_observability_rancher_auth = true`
- When SUSE Observability is enabled, dedicated Ingress resources for OTLP/gRPC and OTLP/HTTP are automatically created to expose the OpenTelemetry Collector
- `sslip.io` is used by default for automatic DNS resolution
- Multi-node deployments automatically configure HA RKE2 server nodes
- OpenWebUI is accessible via the exposed Ingress URL (the first user to register will automatically become the admin).
