#=====================================================#
# Platform LZ: Governance - Policy Custom Definitions
#=====================================================#

locals {
  # Decode all JSON policy files and add metadata. 
  policy_files = fileset("${var.policy_custom_def_path}", "*.json") # Discover all policy JSON files.
  policies = {
    for file_name in local.policy_files :         # Loop each file in the list of files. 
    trimsuffix(file_name, ".json") => jsondecode( # Create map using trimmed file name as key, parsed JSON as value. 
    file("${var.policy_custom_def_path}/${file_name}")).properties
  }
}

# Loop each JSON file in directory and create Policy Definition. 
resource "azurerm_policy_definition" "custom" {
  for_each     = local.policies # Local map variable of policy names and content. 
  name         = each.key       # Use trimmed filename as policy definition name. 
  policy_type  = "Custom"
  mode         = each.value.mode
  display_name = "[${upper(var.stack_code)}] ${upper(split("_", each.key)[0])} - ${each.value.displayName}"
  description  = try(each.value.description, null)          # Try if it exists, use it - otherwise use null.
  metadata     = jsonencode(try(each.value.metadata, {}))   # Try if it exists, use it - otherwise empty. 
  parameters   = jsonencode(try(each.value.parameters, {})) # Try if it exists, use it - otherwise empty. 
  policy_rule  = jsonencode(each.value.policyRule)
}
