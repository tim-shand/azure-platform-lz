# Azure: Platform Landing Zone (STACK: Governance)

This stack deploys the Governance layer for a custom, light-weight, CAF-aligned platform landing zone in Azure. 

## 🌟 Features

- Provides basic security and management controls allowing assignment of built-in Azure Policy initiatives. 
- Creates custom Policy Definitions as defined in JSON files. 
- Creates custom Policy Initiatives, grouping Policy Definitions into categories. 
- Assignment of policy initiatives to Management Groups, using a list field from the Management Group structure. 
- Driven using workflow/pipeline with supplied variables and secrets. 

### Management Groups

- Deployed using structures defined within the `governance.tfvars` file. 
- Management Groups are assigned to a "Level", which determines the layer of depth the Management Group sits. 
- Levels 2 and below are assigned to a parent Management Group from Level 1 based on provided Management Group name. 

### Policy

- Policy Definitions are defined in JSON files within the `policy_definitions` directory. 
- Policy Initiatives are created using the Policy Definitions defined in the `policy_initiatives` variable within the `governance.tfvars` file. 
- Policy Initiatives are mapped to Management Groups using the `policy_initiatives` field in the Management Group structure. 

```hcl
# Define Initiative -> Definition mapping.
policy_initiatives = { 
  core_baseline = [
    "allowed_locations",
    "required_tag_list",
    "storage_accounts_https"
  ]
  cost_controls = [
    "restrict_vm_skus"
  ]
  decommissioned = [
    "deny_all_resources"
  ]
}
```

### Example Structure

```hcl
management_groups_level1 = { # Management Groups: First level nested under the root manangement group. 
  "workloads" = {
    display_name           = "Workloads"       # Contains the landing zone child management groups for workloads. 
    subscription_id_filter = [""]              # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    policy_initiatives     = ["cost_controls"] # Assign Policy Initiatives directly to MGs. 
  }
}
management_groups_level2 = {
  "online" = {
    display_name           = "Online"               # Workloads requiring direct internet inbound or outbound connectivity, or may not require a virtual network.
    subscription_id_filter = ["0000000-0000-0000"]  # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    parent_mg_name         = "workloads"
    policy_initiatives     = [] # Assign Policy Initiatives directly to MGs. 
  }
  "corporate" = {
    display_name           = "Corporate" # Workloads that require connectivity with the corporate/on-prem network via the hub in the connectivity subscription. 
    subscription_id_filter = []          # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    parent_mg_name         = "workloads"
    policy_initiatives     = [] # Assign Policy Initiatives directly to MGs. 
  }
}
```

---

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
