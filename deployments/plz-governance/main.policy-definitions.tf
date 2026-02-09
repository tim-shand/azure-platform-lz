#====================================================================================#
# Governance: Policy Definitions
# Description: 
# - Create Policy Definitions from local JSON files. 
# - Deploy these once, at the root MG level. 
#====================================================================================#

locals {
  policy_files_path = "${path.module}/policy_definitions"             # Supply path to JSON files. 
  policy_files      = fileset("${local.policy_files_path}", "*.json") # Decode all JSON policy files and add metadata.
  policies = {
    for file_name in local.policy_files :         # Loop each file in the list of files. 
    trimsuffix(file_name, ".json") => jsondecode( # Create map using trimmed file name as key, parsed JSON as value. 
    file("${local.policy_files_path}/${file_name}")).properties
  }
}

# Policy: Definitions - Loop each JSON file in directory and create Policy Definition. 
resource "azurerm_policy_definition" "custom" {
  for_each            = local.policies # Local map variable of policy names and content. 
  name                = each.key       # Use trimmed filename as policy definition name. 
  policy_type         = "Custom"
  mode                = each.value.mode
  management_group_id = local.management_groups_all_created.core.id # Create at core MG for use with all subs and MGs.
  display_name        = "[${upper(var.stack.naming.workload_code)}] - ${each.value.displayName}"
  description         = try(each.value.description, null)          # Try if it exists, use it - otherwise use null.
  metadata            = jsonencode(try(each.value.metadata, {}))   # Try if it exists, use it - otherwise empty. 
  parameters          = jsonencode(try(each.value.parameters, {})) # Try if it exists, use it - otherwise empty. 
  policy_rule         = jsonencode(each.value.policyRule)
}
