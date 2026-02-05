# Azure: Platform Landing Zone (STACK: Governance)

This stack deploys the Governance layer for a custom, light-weight, CAF-aligned platform landing zone in Azure. 

## 🌟 Features

- Provides basic security and management controls allowing assignment of built-in Azure Policy initiatives. 
- Creates custom Policy Definitions as defined in JSON files. 
- Creates custom Policy Initiatives, grouping Policy Definitions into categories. 
- Assignment of policy initiatives to Management Groups, using a list field from the Management Group structure. 

### Management Groups

- Deployed using structures defined within the `plz-governance.tfvars` file. 
- Management Groups are assigned to a "Level", determining the layer of depth that the Management Group sits. 
- Levels 2 and below are assigned to a parent Management Group from Level 1 based on provided Management Group name. 

### Policy

- Policy Definitions are defined in JSON files within the `policy_definitions` directory. 
- Policy Initiatives are created using the Policy Definitions defined in the `policy_initiatives` variable within the `plz-governance.tfvars` file. 
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

### Example Variable Structure

```hcl
management_groups_level1 = {
  "platform" = {
    display_name             = "Platform"                               # Contains all platform subscriptions (management, connectivity, security and identity). 
    subscription_identifiers = ["platform-iac-sub", "platform-plz-sub"] # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
    policy_initiatives       = []                                       # Assign Policy Initiatives directly to MGs. 
  }
  "workload" = {
    display_name             = "Workload" # Contains the landing zone child management groups for workloads. 
    subscription_identifiers = []         # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
    policy_initiatives       = []         # Assign Policy Initiatives directly to MGs. 
  }
  "sandbox" = {
    display_name             = "Sandbox"                # Contains subscriptions for testing. Isolated from corporate and online landing zones. Less restrictive set of policies assigned. 
    subscription_identifiers = ["visualstudio-dev-sub"] # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
    policy_initiatives       = []                       # Assign Policy Initiatives directly to MGs
  }
  "decom" = {
    display_name             = "Decommissioned" # Contains cancelled subscriptions. Deny resource creation via policy. 
    subscription_identifiers = []               # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
    policy_initiatives       = []               # Assign Policy Initiatives directly to MGs. 
  }
}
```

---

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
