# Azure Virtual Machine RKE2 Project

This project deploys an RKE2 Kubernetes cluster on Azure using Terraform/OpenTofu.

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
  - `subscription_id` To specify Azure Subscription ID where resources will be created
- Make sure you are logged into your Azure account from your local Terminal. See the preparatory steps [here](../../../modules/infrastructure/azure/README.md).

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

## Minimal single-node RKE2 cluster

```hcl
prefix         = "<PREFIX>"
subscription_id         = "<SUBSCRIPTION_ID>"

instance_count = 1
```

## HA RKE2 cluster with Longhorn

```hcl
prefix                  = "<PREFIX>"
subscription_id         = "<SUBSCRIPTION_ID>"

instance_count          = 3

longhorn_enabled        = true
longhorn_admin_password = "************"
```

## HA RKE2 cluster with Rancher

```hcl
prefix                     = "<PREFIX>"
subscription_id            = "<SUBSCRIPTION_ID>"
instance_count             = 3

longhorn_enabled           = true
longhorn_admin_password    = "************"

rancher_enabled            = true
rancher_bootstrap_password = "************"
```

## Full stack deployment

```hcl
prefix                          = "<PREFIX>"
subscription_id            = "<SUBSCRIPTION_ID>"
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
- Multi-node deployments automatically configure HA RKE2 server nodes
