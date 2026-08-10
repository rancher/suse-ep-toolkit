# Terraform | Google Cloud - Preparatory steps

In order for Terraform to run operations on your behalf, you must [install and configure the gcloud SDK tool](https://cloud.google.com/sdk/docs/install-sdk).

## Example

#### macOS installation and setup

```bash
brew install --cask google-cloud-sdk
```

```bash
gcloud components install gke-gcloud-auth-plugin
```

```bash
gcloud init
```

```bash
gcloud auth application-default login
```

##### If there are other active accounts, run

```bash
gcloud config set account `ACCOUNT`
```
