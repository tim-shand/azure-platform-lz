locals {
  tags_merged = merge(var.global.tags, var.tags) # Merge global tags with stack tags. 
  # Map groups of policy definitions by prefix to target management group. 
  policy_groups = {
    core = {
      for name, p in module.gov_policy_definitions_custom.policies :
      name => p if startswith(name, "core_")
    }
    platform = {
      for name, p in module.gov_policy_definitions_custom.policies :
      name => p if startswith(name, "platform_")
    }
    workloads_prd = {
      for name, p in module.gov_policy_definitions_custom.policies :
      name => p if startswith(name, "workloads_prd_")
    }
    workloads_dev = {
      for name, p in module.gov_policy_definitions_custom.policies :
      name => p if startswith(name, "workloads_dev_")
    }
    sandbox = {
      for name, p in module.gov_policy_definitions_custom.policies :
      name => p if startswith(name, "sandbox_")
    }
    decommissioned = {
      for name, p in module.gov_policy_definitions_custom.policies :
      name => p if startswith(name, "decom_")
    }
  }
}
