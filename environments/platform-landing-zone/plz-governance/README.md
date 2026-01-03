# Azure: Platform Landing Zone (STACK: Governance)

## Overview

This stack deploys a light-weight, CAF-aligned governance layer for use with small business or personal Azure environments. This stack provides basic security and management controls using built-in Azure Policy initiatives, running in Audit mode by default, and is designed to be low-cost and minimal complexity.

- Tag enforcement for resources (Environment, Owner)
- HTTPS-only enforcement for storage accounts
- Allowed locations to restrict deployments to approved regions

## Process

- Deploy management group hierarchy. 
- Deploy policy definitions & initiatives. 
- Deploy policy assignments. 

## Requirements / Notes

### Subscription Naming Convention

Subscription display names **MUST** use a uniform naming convention to enable the automatic assignment to Management Groups. 
For example: `sub-mgt-azure`, where the `mgt` portion is defined in variable `gov_management_group_list` and associated to a parent amanagement group using the `subscription_identifier` value. 

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.5.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.40.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_plz_governance"></a> [plz\_governance](#module\_plz\_governance) | ../../../modules/plz-governance | n/a |

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gov_management_group_list"></a> [gov\_management\_group\_list](#input\_gov\_management\_group\_list) | Map of Management Group configuration to deploy. | <pre>map(object({ # Use object variable name as management group 'name'.<br/>    display_name            = string<br/>    subscription_identifier = optional(string)       # Used to identify existing subscriptions to add to the management group.<br/>    subscription_list       = optional(list(string)) # Provide raw subscription IDs if not match 'subcription_identifier'. <br/>  }))</pre> | n/a | yes |
| <a name="input_gov_management_group_root"></a> [gov\_management\_group\_root](#input\_gov\_management\_group\_root) | Name of the top-level Management Group (root). | `string` | n/a | yes |
| <a name="input_gov_policy_allowed_locations"></a> [gov\_policy\_allowed\_locations](#input\_gov\_policy\_allowed\_locations) | List of allowed resource locations approved when assigning policy. | `list(string)` | n/a | yes |
| <a name="input_gov_policy_builtin"></a> [gov\_policy\_builtin](#input\_gov\_policy\_builtin) | Map of built-in policies and initiatives, required for top-level assignment. | <pre>map(object({<br/>    id           = string<br/>    display_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region to deploy resources into. | `string` | n/a | yes |
| <a name="input_naming"></a> [naming](#input\_naming) | A map of naming values to use with resources. | `map(string)` | `{}` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID for the target changes. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_plz_governance_mg_root"></a> [plz\_governance\_mg\_root](#output\_plz\_governance\_mg\_root) | Name ID of the top-level management group. |
<!-- END_TF_DOCS -->
