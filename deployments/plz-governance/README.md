# Azure: Platform Landing Zone (STACK: Governance)

This stack deploys the Governance layer for a custom, light-weight, CAF-aligned platform landing zone in Azure. 

## 🌟 Features

### Management Groups

- Deploy Management Group structure defined within the `plz-governance.tfvars` file. 
- Management Groups are assigned to a "Level", determining the layer of depth at which each Management Group sits. 
- Levels 2 and below are assigned to a parent Management Groups from Level 1 based on provided Management Group name. 
- Automated subscription assignments using name value identifiers. 

![Management Group hierarchy and subscription assignments.](../docs/images/gov_mg_subs_01.png)

### Policy Definitions and Initiatives

- Policy Definitions are defined in JSON files within the `policy_definitions` directory. 
- Policy Initiatives are created using the Policy Definitions defined in the `policy_initiatives` variable within the `plz-governance.tfvars` file. 
- Policy Initiatives are mapped to Management Groups using the `policy_initiatives` field in the Management Group structure. 
- Built-in Policy Initiatives are resolved by ID and assigned to target Management Groups in the `policy_initiatives_builtin` variable. 

![Azure Policy Definitions and Initiatives.](../docs/images/gov_policy_01.png)

## Example Structure

**Management Group Structure, Subscription Assignments, Policy Mapping**  

```hcl
# Management Group Structure. 
management_groups_level1 = {
  "platform" = {
    display_name             = "Platform"                               # Contains all platform subscriptions (management, connectivity, security and identity). 
    subscription_identifiers = ["platform-iac-sub", "platform-plz-sub"] # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
    policy_initiatives       = ["core_baseline"]                        # Assign Policy Initiatives directly to MGs. 
  }
  "workload" = {
    display_name             = "Workload"                 # Contains the landing zone child management groups for workloads. 
    subscription_identifiers = ["visualstudio-dev-sub"]   # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
    policy_initiatives       = ["cost_controls"]          # Assign Policy Initiatives directly to MGs. 
  }
}

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
}

```

---

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
