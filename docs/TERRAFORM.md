# Terraform CLI - Preparatory steps

Install the Terraform Command Line Interface [(CLI)](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform) to manage infrastructure and interact with Terraform state, providers, configuration files, and Terraform Cloud.

## Example

#### macOS installation and setup

```bash
brew tap hashicorp/tap
```

```bash
brew install hashicorp/tap/terraform
```

```bash
brew update
```

```bash
brew upgrade hashicorp/tap/terraform
```

```bash
terraform version
```

##### How to enable tab completion

```console 
$ which terraform
/opt/homebrew/bin/terraform
$ echo "complete -C /opt/homebrew/bin/terraform terraform" >> ~/.bash_profile
$ source ~/.bash_profile
```
