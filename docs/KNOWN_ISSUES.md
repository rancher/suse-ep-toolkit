# Known Issues

This document outlines known issues, limitations, and workarounds when deploying or managing infrastructure with `suse-ep-toolkit`.

---

## SUSE Application Collection Rate Limits (`429 Too Many Requests`)

### Symptom

During `terraform apply`, `terraform plan`, or `terraform destroy` operations involving the `suse-ai` module (or any other module pulling OCI Helm charts from SUSE Application Collection), Terraform fails with an HTTP `429 Too Many Requests` error:

```text
╷
│ Error: Error locating chart
│ 
│   with module.suse_ai.helm_release.milvus[0],
│   on ../../../modules/distribution/suse-ai/main.tf line 65, in resource "helm_release" "milvus":
│   65: resource "helm_release" "milvus" {
│ 
│ Unable to locate chart oci://dp.apps.rancher.io/charts/milvus: failed to perform "FetchReference" on source: GET
│ "https://dp.apps.rancher.io/v2/charts/milvus/manifests/4.2.2": response status code 429: Too Many Requests
╵
```

### Root Cause

1. **Registry Pull Quotas:** The SUSE Application Collection OCI registry (`dp.apps.rancher.io`) enforces rate limits on manifest and chart pulls. Unauthenticated requests or accounts exceeding their allocated hourly/daily pull quota will be throttled.
2. **Terraform Concurrency & Refresh:** By default, Terraform executes up to 10 operations in parallel, triggering simultaneous `FetchReference` calls to `dp.apps.rancher.io` during `apply`. Similarly, `terraform destroy` refreshes the state by querying the remote OCI registry before tearing down resources.

### How to Check Your Rate Limit

You can inspect your current usage and remaining pull quota directly from the SUSE Application Collection portal:

1. Navigate to your profile settings at [https://apps.rancher.io/settings/profile](https://apps.rancher.io/settings/profile).
2. Scroll down to the **Rate Limits** section to check your current request consumption and reset window.

![](../images/KNOWN_ISSUES_1.jpg)

### Workarounds & Prevention

#### 1. Bypass Registry Refresh During `terraform destroy`

If the error occurs while tearing down an environment, skip the remote state refresh so Terraform does not query `dp.apps.rancher.io` for chart metadata:

```bash
terraform destroy -refresh=false --auto-approve
```

#### 2. Authenticate to the OCI Registry

Ensure you are logged in to `dp.apps.rancher.io` with a valid SUSE Application Collection account so your requests are not subject to stricter anonymous rate limits:

```bash
helm registry login dp.apps.rancher.io -u <YOUR_USERNAME>
```

#### 3. Reduce Terraform Parallelism During `terraform apply`

If you hit burst limits when deploying multiple Helm releases simultaneously, limit Terraform's concurrency:

```bash
terraform apply -parallelism=1
```

---
