# DigitalOcean K3s Project

This project deploys a K3s Kubernetes cluster on DigitalOcean using Terraform/OpenTofu.

The deployment can optionally install and configure:

- Longhorn
- Rancher
- NeuVector
- SUSE Observability

All components are deployed automatically using reusable modules from the repository.

# How to create resources

- Copy `./terraform.tfvars.example` to `./terraform.tfvars`
- Edit `./terraform.tfvars`
- Configure the required variables:
  - `prefix` to give the resources an identifiable name (e.g., your initials or first name)
  - `do_token` to specify the DigitalOcean API token used to create resources

Example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

# Component relationships and requirements

Some components depend on others and cannot be enabled independently.

## Longhorn

Longhorn requires:

- `instance_count >= 3`
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

# Example deployment scenarios

## Minimal single-node K3s cluster

```hcl
prefix         = "<PREFIX>"
do_token       = "<DIGITALOCEAN_TOKEN>"
instance_count = 1
```

## HA K3s cluster with Longhorn

```hcl
prefix                  = "<PREFIX>"
do_token                = "<DIGITALOCEAN_TOKEN>"
instance_count          = 3

longhorn_enabled        = true
longhorn_admin_password = "************"
```

## HA K3s cluster with Rancher

```hcl
prefix                     = "<PREFIX>"
do_token                   = "<DIGITALOCEAN_TOKEN>"
instance_count             = 3

longhorn_enabled           = true
longhorn_admin_password    = "************"

rancher_enabled            = true
rancher_bootstrap_password = "************"
```

## Full stack deployment

```hcl
prefix                          = "<PREFIX>"
do_token                        = "<DIGITALOCEAN_TOKEN>"
instance_count                  = 3

longhorn_enabled                = true
longhorn_admin_password         = "************"

rancher_enabled                 = true
rancher_bootstrap_password      = "************"

neuvector_enabled               = true
neuvector_admin_password        = "************"

suse_observability_enabled      = true
suse_observability_license      = "<LICENSE>"
suse_observability_rancher_auth = true
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

# How to execute kubectl commands

After deployment:

```bash
export KUBECONFIG=<PREFIX>_kubeconfig.yaml
```

# How to access cluster nodes

```bash
ssh -oStrictHostKeyChecking=no \
  -i <PREFIX>-ssh_private_key.pem \
  opensuse@<PUBLIC_IPV4>
```

# Exposed services

Depending on enabled components, the following services become available:

| Component | URL |
|---|---|
| Rancher | `https://rancher.<NODE_IP>.sslip.io` |
| Longhorn | `https://longhorn.<NODE_IP>.sslip.io` |
| NeuVector | `https://neuvector.<NODE_IP>.sslip.io` |
| SUSE Observability | `https://suse-observability.<NODE_IP>.sslip.io` |
| OpenTelemetry (OTLP/gRPC) | `https://otlp-observability.<NODE_IP>.sslip.io` |
| OpenTelemetry (OTLP/HTTP) | `https://otlp-http-observability.<NODE_IP>.sslip.io` |

# Notes

- TLS certificates are automatically generated
- Longhorn UI is protected with Traefik Basic Authentication
- NeuVector automatically integrates with Rancher SSO when Rancher is enabled
- SUSE Observability supports Rancher OIDC authentication, which can be enabled by setting `suse_observability_rancher_auth = true`
- When SUSE Observability is enabled, dedicated Ingress resources for OTLP/gRPC and OTLP/HTTP are automatically created to expose the OpenTelemetry Collector
- `sslip.io` is used by default for automatic DNS resolution
- Multi-node deployments automatically configure HA K3s server nodes
