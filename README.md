# suse-ep-toolkit

A modular Terraform/OpenTofu toolkit for deploying and managing SUSE Emerging Products tools on cloud providers.

The project provides reusable infrastructure and distribution modules for deploying Kubernetes clusters and SUSE Emerging Products components such as NeuVector and SUSE Observability.

## Why?

To simplify the deployment of complete SUSE Emerging Products environments on cloud providers using reusable and composable Terraform/OpenTofu modules.

The toolkit focuses on:

- Rapid Kubernetes cluster provisioning
- SUSE Emerging Products integration
- Infrastructure modularity
- Reusable deployment recipes
- Easy lab and PoC environments
- Cloud-native automation

:warning: **Not intended for production use.**

## Currently supported components

### Kubernetes Distribution

- RKE2
- K3s

### SUSE Products

- Rancher 
- Longhorn

### SUSE Emerging Products

- NeuVector
- SUSE Observability

### Infrastructure Providers

- AWS
- DigitalOcean
- Azure

## How the repository is structured

```console
.
├── modules/
│   ├── custom-os-image/
│   │   ├── aws/
│   │   ├── azure/
│   │   ├── digitalocean/
│   │   └── google-cloud/
│   ├── distribution/
│   │   ├── k3s/
│   │   ├── longhorn/
│   │   ├── neuvector/
│   │   ├── rancher/
│   │   ├── rke2/
│   │   └── suse-observability/
│   ├── identity/
│   │   └── ssh/
│   │       ├── aws/
│   │       ├── azure/
│   │       ├── digitalocean/
│   │       └── google-cloud/
│   └── infrastructure/
│       ├── aws/
│       ├── azure/
│       ├── digitalocean/
│       └── google-cloud/
├── projects/
│   ├── aws/
│   │   ├── k3s/
│   │   └── rke2/
│   ├── azure/
│   │   ├── k3s/
│   │   └── rke2/
│   ├── digitalocean/
│   │   ├── k3s/
│   │   └── rke2/
│   └── google-cloud/
│       ├── k3s/
│       └── rke2/
└── README.md
```

The `modules/` directory contains reusable Terraform/OpenTofu modules organized by category:

- `distribution/` contains Kubernetes and SUSE platform deployment modules
- `infrastructure/` contains cloud provider infrastructure modules
- `identity/` contains identity and SSH-related modules
- `custom-os-image/` contains modules used to prepare and manage custom operating system images

The `projects/` directory combines multiple modules together to provide ready-to-use deployment recipes for specific environments and use cases.

## Available modules

### Distribution modules

- `rke2`
- `k3s`
- `rancher`
- `longhorn`
- `neuvector`
- `suse-observability`

### Infrastructure modules

- `aws/ec2`
- `digitalocean/droplet`
- `azure/virtual-machine`
- `google-cloud/compute-engine`

### Identity modules

- `ssh/aws`
- `ssh/digitalocean`
- `ssh/azure`
- `ssh/google-cloud`

## Documentation

Each module contains its own `docs.md` file with:
- Usage examples
- Variables description
- Outputs
- Configuration notes
- Deployment requirements

## Available projects

### AWS

- `projects/aws/rke2`
- `projects/aws/k3s`

This project can deploy:

- Single-node RKE2/K3s clusters
- Multi-node HA RKE2/K3s clusters
- Longhorn storage
- Rancher
- NeuVector
- SUSE Observability

using AWS EC2 instances.

### DigitalOcean

- `projects/digitalocean/rke2`
- `projects/digitalocean/k3s`

This project can deploy:

- Single-node RKE2/K3s clusters
- Multi-node HA RKE2/K3s clusters
- Longhorn storage
- Rancher
- NeuVector
- SUSE Observability

using DigitalOcean Droplets.

### Azure

- `projects/digitalocean/rke2`
- `projects/digitalocean/k3s`

This project can deploy:

- Single-node RKE2/K3s clusters
- Multi-node HA RKE2/K3s clusters
- Longhorn storage
- Rancher
- NeuVector
- SUSE Observability

using Azure Virtual Machines.

### Google Cloud

- `projects/google-cloud/rke2`
- `projects/google-cloud/k3s`

This project can deploy:

- Single-node RKE2/K3s clusters
- Multi-node HA RKE2/K3s clusters
- Longhorn storage
- Rancher
- NeuVector
- SUSE Observability

using Google Cloud Compute Engine VM instances.

## Features

- Modular architecture
- Terraform and OpenTofu compatible
- Multi-node RKE2/K3s support
- Automatic TLS generation
- Traefik ingress integration
- Longhorn persistent storage
- Rancher integration
- NeuVector Rancher SSO integration
- Longhorn UI basic authentication
- Customizable Helm chart versions
- Cloud-init support
- Custom OS image support

## Getting started

Example:

```bash
cd projects/digitalocean/rke2

cp terraform.tfvars.example terraform.tfvars

terraform init
terraform plan
terraform apply
```

## Requirements

- Terraform or OpenTofu
- kubectl
