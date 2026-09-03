# Deploy SUSE EP Toolkit Test Environment

This document provides a step-by-step guide to provisioning a complete test laboratory environment using **suse-ep-toolkit** on Google Cloud Platform (GCP) using K3s, including Longhorn, Rancher, SUSE Observability, and NeuVector.

## Overview

In this guide, you will learn how to:
* Provision a full SUSE EP Toolkit test environment with all supported stack components.
* Configure deployment parameters such as instance scaling, OS images, and credentials via Terraform.
* Deploy the infrastructure and underlying Helm charts on Google Cloud Platform using K3s.
* Retrieve deployment outputs and access information for installed components.

## Deploying the Test Lab Environment

This section describes how to provision the complete suse-ep-toolkit test infrastructure using Terraform on Google Cloud Platform.

### Step 1: Select the Cloud Provider Project

Clone the repository and navigate to the GCP K3s project directory inside `suse-ep-toolkit`:

```bash
git clone git@github.com:rancher/suse-ep-toolkit.git
cd suse-ep-toolkit/projects/google-cloud/k3s
```

### Step 2: Configure `terraform.tfvars`

Create or update your terraform.tfvars file in the current directory to configure your deployment parameters and enable the required toolkit components:

```bash
prefix                            = "glovecchio"
project_id                        = "<PROJECT_ID>"
region                            = "europe-west8"
instance_count                    = 5	
spot_instance                     = false
ami_id                            = "opensuse-leap-16-0-v20260629-x86-64"
longhorn_enabled                  = true
longhorn_admin_password           = "<LONGHORN_ADMIN_PASSWORD>"
rancher_enabled                   = true
rancher_bootstrap_password        = "<RANCHER_BOOTSTRAP_PASSWORD>"
suse_observability_enabled        = true
suse_observability_license        = "<SUSE_OBSERVABILITY_LICENSE>"
suse_observability_admin_password = "<SUSE_OBSERVABILITY_ADMIN_PASSWORD>"
suse_observability_rancher_auth   = false
neuvector_enabled                 = true
neuvector_admin_password          = "<NEUVECTOR_ADMIN_PASSWORD>"
```

Note on `ami_id` Parameter:

- Default behavior: If `ami_id` is left unspecified, the automation uses a custom OS image built by our team, based on OpenSUSE Leap 16.0. This image comes pre-loaded with all required packages and has been extensively tested to ensure full stability and compatibility.

- Marketplace images: You may explicitly specify an official cloud provider Marketplace image (e.g., Google Cloud Marketplace). While this significantly reduces provisioning times by bypassing the download and upload steps of the custom image, full compatibility cannot be guaranteed.

- Supported distributions: A strict validation check is enforced in code: only images based on OpenSUSE Leap are supported.

### Step 3: Deploy Infrastructure via Terraform

Initialize the Terraform working directory and apply the configuration:

```bash
terraform init -upgrade && terraform apply -auto-approve
```

Wait until Terraform finishes provisioning all infrastructure resources and Helm charts on the local cluster.

*Tip - Retrieving Outputs Later:*

If you need to view or inspect the deployment outputs (such as URLs, credentials, or IP addresses) at any time after the initial terraform apply, you can run:

```bash
terraform output
```

![](./images/DEPLOY_SUSE_EP_TOOLKIT_1.png)
