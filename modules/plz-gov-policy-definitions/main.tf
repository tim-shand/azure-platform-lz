#=====================================================#
# Platform LZ: Governance - Policy Definitions
#=====================================================#

locals {
  policy_files = fileset("${var.policy_custom_def_path}", "${lower(var.filter_string)}_*.json") # Set file path for JSON files (filtered on JSON extension). 
  policies = {
    for file_name in local.policy_files :         # Loop each file in the list of files. 
    trimsuffix(file_name, ".json") => jsondecode( # Create map using trimmed file name as key, content as value. 
      file("${var.policy_custom_def_path}/${file_name}")
    ).properties
  }
}

# Loop each JSON file in directory and create Policy Definition. 
resource "azurerm_policy_definition" "custom" {
  for_each     = local.policies # Local map variable of policy names and content. 
  name         = each.key       # Use trimmed filename as policy definition name. 
  policy_type  = "Custom"
  mode         = each.value.mode
  display_name = "[${upper(var.stack_code)}] ${var.filter_string} - ${each.value.displayName}"
  description  = try(each.value.description, null)          # Try if it exists, use it - otherwise use null.
  metadata     = jsonencode(try(each.value.metadata, {}))   # Try if it exists, use it - otherwise empty. 
  parameters   = jsonencode(try(each.value.parameters, {})) # Try if it exists, use it - otherwise empty. 
  policy_rule  = jsonencode(each.value.policyRule)
}
