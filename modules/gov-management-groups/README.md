# Terraform Module: Azure \[Governance\] - Management Groups

This Terraform module creates and manages **Azure Management Groups (MGs)** with optional subscription associations. It supports **nested management groups**, dynamic subscription assignment using **subscription ID prefixes**, and is designed for governance-focused landing zones. 

---

## Features

- Creates a **root management group**. 
- Creates management groups up to **four levels nested**. 
- Automatically assign subscriptions to MGs based on **first 3 segments of subscription IDs**. 
- Supports **multiple subscriptions per MG**. 
- Supports **nested MGs**, with parent-child relationships explicitly defined. 
- Designed to work with **Azure Policy assignments** and role-based access control (RBAC). 

---

## Usage

```hcl
data "azurerm_subscriptions" "all" {} # Get all subscriptions visible to current identity. 

module "management-groups" {
  source                = "../../modules/gov-management-groups"
  global                = var.global                                   # Global configuration and other shared variables.
  subscriptions         = data.azurerm_subscriptions.all.subscriptions # Pass in all subscriptions from data call. 
  management_group_root = "Core"                                       # Root: Top-level MG representign the organisation. 
  management_groups_level1 = {                                         # Level 1: Nested under root MG.
    platform = {
      display_name           = "Platform"
      subscription_id_filter = ["00000000-0000-0000", "11111111-1111-1111"]
    }
    workloads = {
      display_name           = "Workloads"
      subscription_id_filter = []
    }
    sandbox = {
      display_name           = "Sandbox"
      subscription_id_filter = ["22222222-2222-2222"]
    }
    decom = {
      display_name           = "Decommissioned"
      subscription_id_filter = []
    }
  }
  management_groups_level2 = { # Level 2: Nested under level 1 MGs. 
    online = {
      display_name           = "Online"
      subscription_id_filter = ["33333333-3333-3333"]
      parent_mg_name         = "workloads"
    }
    corporate = {
      display_name           = "Corporate"
      subscription_id_filter = []
      parent_mg_name         = "workloads"
    }
  }
  management_groups_level3 = {} # Level 3: Nested under level 2 MGs. Leave blank "{}" if not required.
  management_groups_level4 = {} # Level 4: Nested under level 3 MGs. Leave blank "{}" if not required. 
}
```
