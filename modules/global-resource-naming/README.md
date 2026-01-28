# 🚀 Terraform Module: Global Resource Naming

This module generates consistent, CAF-aligned Azure resource names for both platform and workloads resources. Supports dash-separated names and compact names for name-restricted resources like Storage Accounts and Key Vaults as accessible outputs.  

## ✅ Features

- Produces multiple name values, both separated by `-` and compact (no separators). 
- Enforces lower-case for all naming methods. 
- Compact names are alphanumeric, and truncated to max_length_compact. 
- Random suffixes ensure unique naming for globally-scoped resources (Storage Accounts and Key Vaults).
- Suffixes for `sa` and `kv` are automatically appended to relevant outputs for convenience. 

---

## 💡 Usage

```hcl
module "naming_mywebapp" {
  source          = "./modules/global-resource-naming"
  prefix          = "abc"
  workload        = "mywebapp"
  stack_or_env    = "prd"
  category        = "www"
  ensure_unique   = true
  random_length   = 6
  max_length_full = 64
  max_length_compact = 24
}
```

---

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Organisation prefix/abbreviation. Example: abc. | `string` | n/a | yes |
| <a name="input_stack_or_env"></a> [stack\_or\_env](#input\_stack\_or\_env) | Deployment stack or environment. Example: con, gov, prd, dev, tst. | `string` | n/a | yes |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload or project name. Example: plz or mywebapp. | `string` | n/a | yes |
| <a name="input_category"></a> [category](#input\_category) | Optional category for platform or service based grouping. Example: hub, log, www. | `string` | `""` | no |
| <a name="input_ensure_unique"></a> [ensure\_unique](#input\_ensure\_unique) | Enable to append a random suffix for unique naming. | `bool` | `false` | no |
| <a name="input_max_length_compact"></a> [max\_length\_compact](#input\_max\_length\_compact) | Maximum length of compact names (for restricted resources like Storage Accounts). | `number` | `24` | no |
| <a name="input_max_length_full"></a> [max\_length\_full](#input\_max\_length\_full) | Maximum length for full, dash separated names. | `number` | `64` | no |
| <a name="input_random_length"></a> [random\_length](#input\_random\_length) | Length of random string if uniqueness is required. | `number` | `6` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compact_name"></a> [compact\_name](#output\_compact\_name) | Compact name with no separator (truncated if necessary). |
| <a name="output_compact_name_long"></a> [compact\_name\_long](#output\_compact\_name\_long) | Compact name with no separator, not truncated. |
| <a name="output_compact_name_unique"></a> [compact\_name\_unique](#output\_compact\_name\_unique) | Compact name with no separator and unique suffix (truncated to max\_length\_compact). |
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | Full length name separated by dashes. |
| <a name="output_full_name_unique"></a> [full\_name\_unique](#output\_full\_name\_unique) | Full length name separated by dashes, with a unique suffix. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | Pre-determined name for Key Vault. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Pre-determined name for Storage Account. |

## Modules

No modules.
<!-- END_TF_DOCS -->

---
