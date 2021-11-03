# Fluentbit Systemd Input

This module registers metrics collected by the Systemd [input plugin](https://docs.fluentbit.io/manual/pipeline/inputs/systemd)

## Usage

```hcl
provider "observe" {}

data "observe_workspace" "default" {
  name = "Fluentbit"
}

module "fluentbit" {
  source    = "git@github.com:observeinc/terraform-observe-fluentbit.git"
  workspace = data.observe_workspace.default
  path      = "/fluentbit"
}

module "fluentbit_systemd" {
  source       = "git@github.com:observeinc/terraform-observe-fluentbit.git//inputs/systemd"
  workspace    = data.observe_workspace.default
  fluentbit    = module.fluentbit
  extract_tags = ["host", "datacenter"]
  link_targets = {
    "host": {
      "target": module.fluentbit.host.oid,
      "fields": ["host", "datacenter"],
    }
  }
  name_format  = "Fluentbit/%s"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_observe"></a> [observe](#requirement\_observe) | ~> 0.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_observe"></a> [observe](#provider\_observe) | 0.4.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|

| observe_dataset.cpu_metrics | resource |

| observe_link.cpu_metrics | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extract_tags"></a> [extract\_tags](#input\_extract\_tags) | Additional tags to extract as columns. | `list(string)` | `[]` | no |
| <a name="input_link_targets"></a> [link\_targets](#input\_link\_targets) | Datasets to link to. | <pre>map(object({<br>    target = string<br>    fields = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_name_format"></a> [name\_format](#input\_name\_format) | Format string to use for dataset names. Override to introduce a prefix or suffix. | `string` | `"%s"` | no |
| <a name="input_telegraf"></a> [telegraf](#input\_telegraf) | Telegraf module | <pre>object({<br>    events = object({ oid = string })<br>  })</pre> | n/a | yes |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | Workspace to apply module to. | `object({ oid = string })` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cpu_metrics"></a> [cpu\_metrics](#output\_cpu\_metrics) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache 2 Licensed. See LICENSE for full details.

