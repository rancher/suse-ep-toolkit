# OpenTofu CLI - Preparatory steps

Install the OpenTofu Command Line Interface [(CLI)](https://opentofu.org/docs/intro/install/homebrew/).

## Example

#### macOS installation and setup

```bash
brew update
```

```bash
brew install opentofu
```

```bash
tofu version
```

##### How to enable [tab completion](https://opentofu.org/docs/cli/commands/#shell-tab-completion)

```console 
$ which tofu
/opt/homebrew/bin/tofu
$ echo "complete -C /opt/homebrew/bin/tofu tofu" >> ~/.bash_profile
$ source ~/.bash_profile
```
