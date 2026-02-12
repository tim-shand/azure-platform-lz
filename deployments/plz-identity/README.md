# Azure: Platform Landing Zone (Identity Stack)

The Identity stack is responsible for managing Entra ID groups used across your Azure landing zone. This stack centralises the creation of administrator and user groups, ensuring consistent naming, ownership, and active status management. 

⚠️ **NOTE:** This stack does not create service principals, assign RBAC roles, or manage subscription/resource level access. Those tasks belong in the Management or Governance stacks. 

## 🌟 Features

The Identity Stack manages Entra ID resources required for the platform. This includes:

- Admin and User groups created from TFVARS definitions. 
- Only groups marked as active are created. 
- Owners are resolved dynamically using employee IDs. 
- Group names follow enterprise prefix conventions. 
- Groups are security-enabled and duplicate names are prevented. 

---

## 🏦 Architecture

- **Entra ID Groups:** 
  - GRP_ADM_* = Privileged administrator roles. 
  - GRP_USR_* = Standard user or team roles. 
  - Owners = assigned to each group via employee ID. 

```text
Azure Tenant
 └─ Identity Stack
     ├─ Entra ID Admin Groups (GRP_ADM_*)
     └─ Entra ID User Groups (GRP_USR_*)
```

---

## ▶️ Usage

1. Update stack TFVARS file with required group configurations, including owner employee ID. 
2. Deploy the stack using the related workflow in GitHub Actions. 
3. Validate outputs match desired state. 

**Example TFVARS:**  

```hcl
# Entra ID: Set naming format. 
entra_groups_admins_prefix = "GRP_ADM_" # GRP_ADM_NetworkAdmins
entra_groups_users_prefix  = "GRP_USR_" # GRP_ADM_NetworkAdmins

# Admin Groups. 
entra_groups_admins = {
  "NetworkAdmins" = {
    description       = "RBAC - Privilaged Group: Network Administrators"
    active            = true          # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "STAFF123456" # Use dummy employee ID as this is public repo. 
  }
  "PlatformAdmins" = {
    description       = "RBAC - Privilaged Group: Platform Administrators"
    active            = true          # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "STAFF123456" # Use dummy employee ID as this is public repo. 
  }
}

# User Groups. 
entra_groups_users = {
  "FinanceTeam" = {
    description       = "User Access: Finance Department"
    active            = true          # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "STAFF998800" # Use dummy employee ID as this is public repo. 
  }
  "ManagementTeam" = {
    description       = "User Access: Management Department"
    active            = true          # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "STAFF998800" # Use dummy employee ID as this is public repo. 
  }
}
```

---

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.7.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |
| <a name="provider_azurerm.iac"></a> [azurerm.iac](#provider\_azurerm.iac) | 4.57.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_group.grp_adm](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group.grp_usr](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_entra_groups_admins"></a> [entra\_groups\_admins](#input\_entra\_groups\_admins) | Map of objects defining the base groups for privilaged administrator roles. | <pre>map(object({<br/>    description       = string<br/>    active            = bool<br/>    owner_employee_id = string<br/>  }))</pre> | n/a | yes |
| <a name="input_entra_groups_admins_prefix"></a> [entra\_groups\_admins\_prefix](#input\_entra\_groups\_admins\_prefix) | Prefix value to append to administrator group naming format. | `string` | `"GRP_ADM_"` | no |
| <a name="input_entra_groups_users"></a> [entra\_groups\_users](#input\_entra\_groups\_users) | Map of objects defining the base groups for standard user access/team roles. | <pre>map(object({<br/>    description       = string<br/>    active            = bool<br/>    owner_employee_id = string<br/>  }))</pre> | n/a | yes |
| <a name="input_entra_groups_users_prefix"></a> [entra\_groups\_users\_prefix](#input\_entra\_groups\_users\_prefix) | Prefix value to append to user access group naming format. | `string` | `"GRP_USR_"` | no |
| <a name="input_global"></a> [global](#input\_global) | Map of global variables used across multiple deployment stacks. | `map(map(string))` | `{}` | no |
| <a name="input_global_outputs"></a> [global\_outputs](#input\_global\_outputs) | Map of Shared Service key names, used to get IDs and names in data calls. | `map(string)` | n/a | yes |
| <a name="input_global_outputs_name"></a> [global\_outputs\_name](#input\_global\_outputs\_name) | Name of global outputs shared service App Configuration created during bootstrap. | `string` | n/a | yes |
| <a name="input_global_outputs_rg"></a> [global\_outputs\_rg](#input\_global\_outputs\_rg) | Map of global outputs shared service Resource Group for App Configuration created during bootstrap. | `string` | n/a | yes |
| <a name="input_stack"></a> [stack](#input\_stack) | Map of stack specific variables for use within current deployment. | `map(map(string))` | `{}` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID for the stack resources. | `string` | n/a | yes |
| <a name="input_subscription_id_iac"></a> [subscription\_id\_iac](#input\_subscription\_id\_iac) | Subscription ID of the dedicated IaC subscription. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azuread_groups_adm"></a> [azuread\_groups\_adm](#output\_azuread\_groups\_adm) | Map of privilaged Entra ID groups. |
| <a name="output_azuread_groups_usr"></a> [azuread\_groups\_usr](#output\_azuread\_groups\_usr) | Map of standard Entra ID groups. |
<!-- END_TF_DOCS -->