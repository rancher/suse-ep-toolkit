## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_disable_components"></a> [disable\_components](#input\_disable\_components) | Specifies bundled K3s components to disable. Default is empty. | `list(string)` | `[]` | no |
| <a name="input_k3s_config"></a> [k3s\_config](#input\_k3s\_config) | Specifies additional custom K3s configuration in YAML format. Default is empty. | `string` | `""` | no |
| <a name="input_k3s_token"></a> [k3s\_token](#input\_k3s\_token) | Specifies the shared token used by all nodes to join the K3s cluster. Default is 'null'. | `string` | `null` | no |
| <a name="input_k3s_version"></a> [k3s\_version](#input\_k3s\_version) | Specifies the K3s version to install. Default is 'v1.33.5+k3s1'. | `string` | `"v1.33.5+k3s1"` | no |
| <a name="input_node_role"></a> [node\_role](#input\_node\_role) | Specifies the K3s node role for this instance. Valid values are 'server' or 'agent'. The role determines whether the node participates in the control plane cluster ('server') or joins as a worker node ('agent'). Default is 'agent'. | `string` | `"agent"` | no |
| <a name="input_server_url"></a> [server\_url](#input\_server\_url) | Specifies the URL of the first K3s server node (required for 'server' joining an existing cluster and for 'agent'). Default is 'null'. | `string` | `null` | no |
| <a name="input_volume_device"></a> [volume\_device](#input\_volume\_device) | Specifies the volume device mounted on the cloud instance. Default is '/dev/sda/'. | `string` | `"/dev/sda"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_install_type"></a> [install\_type](#output\_install\_type) | Indicates whether the node is installed as 'server' or 'agent'. |
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | Cloud-init user\_data script used to bootstrap the K3s node. |
