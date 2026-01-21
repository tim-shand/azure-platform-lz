# Management Groups: Top-level (root) management group. 
management_group_root = "Core"

# Management Groups: First level nested under the root manangement group.  
management_groups_level1 = {
  "platform" = {
    display_name           = "Platform"                                   # Contains all platform subscriptions (management, connectivity, security and identity). 
    subscription_id_filter = ["56effccd-9f6c-4b5e", "8cf80f38-0042-413a"] # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
  }
  "workloads" = {
    display_name           = "Workloads" # Contains the landing zone child management groups for workloads. 
    subscription_id_filter = []          # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
  }
  "sandbox" = {
    display_name           = "Sandbox"              # Contains subscriptions for testing. Isolated from corporate and online landing zones. Less restrictive set of policies assigned. 
    subscription_id_filter = ["66f229bc-adb1-4b24"] # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
  }
  "decom" = {
    display_name           = "Decommissioned" # Contains cancelled subscriptions. Deny resource creation via policy. 
    subscription_id_filter = []               # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
  }
}

# Management Groups: Second level nested under the parent (first level) management groups. 
management_groups_level2 = {
  "online" = {
    display_name           = "Online"               # Workloads requiring direct internet inbound or outbound connectivity, or may not require a virtual network.
    subscription_id_filter = ["9173fb12-e761-49ab"] # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    parent_mg_name         = "workloads"
  }
  "corporate" = {
    display_name           = "Corporate" # Workloads that require connectivity with the corporate/on-prem network via the hub in the connectivity subscription. 
    subscription_id_filter = []          # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    parent_mg_name         = "workloads"
  }
}

# Management Groups: Third and fourth levels nested under the parent (second level) manangement groups. 
management_groups_level3 = {} # Leave blank if not required. 
management_groups_level4 = {} # Leave blank if not required.
