# Governance: Management Groups -----------------#

gov_management_group_root = "Core" # Top level Management Group name.
gov_management_group_list = {
  platform = {
    display_name            = "Platform" # Cosmetic name for Management Group.
    subscription_identifier = "mgt"      # Used to identify existing subscriptions to add to the Management Groups. 
  }
  workloads = {
    display_name            = "Workloads"
    subscription_identifier = "app"
  }
  sandbox = {
    display_name            = "Sandbox"
    subscription_identifier = "dev"
  }
  decom = {
    display_name            = "Decommission"
    subscription_identifier = "decom"
  }
}

# Governance: Policy Assignments -----------------#

gov_policy_allowed_locations = [
  "australiaeast",
  "australiasoutheast",
  "nznorth",
  "westus2",
  "eastus"
]

gov_policy_builtin = {
  CIS_Microsoft_Azure_Foundations_Benchmark = {
    id           = "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
    display_name = "CIS-MSAzureFoundations"
  }
  Require_Resource_Tags = {
    id           = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
    display_name = "RequireResourceTags"
  }
  Secure_Storage_Account_HTTPS = {
    id           = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
    display_name = "StorageAccountsHTTPS"
  }
}
