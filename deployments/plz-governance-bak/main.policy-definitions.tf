#=====================================================#
# Platform LZ: Governance - Policy Definitions
#=====================================================#

locals {
  policy_files_path = "${path.module}/policy_definitions"             # Decode all JSON policy files and add metadata. 
  policy_files      = fileset("${local.policy_files_path}", "*.json") # Discover all policy JSON files.
  policies = {
    for file_name in local.policy_files :         # Loop each file in the list of files. 
    trimsuffix(file_name, ".json") => jsondecode( # Create map using trimmed file name as key, parsed JSON as value. 
    file("${local.policy_files_path}/${file_name}")).properties
  }
  # Generate map of Policy Definition name (key), ID, name (value). Used with Initiatives. 
  policy_definition_map = {
    for k, p in azurerm_policy_definition.custom :
    k => { id = p.id, name = p.name }
  }
}

# Loop each JSON file in directory and create Policy Definition. 
resource "azurerm_policy_definition" "custom" {
  for_each     = local.policies # Local map variable of policy names and content. 
  name         = each.key       # Use trimmed filename as policy definition name. 
  policy_type  = "Custom"
  mode         = each.value.mode
  display_name = "[${upper(var.naming.stack_code)}] - ${each.value.displayName}"
  description  = try(each.value.description, null)          # Try if it exists, use it - otherwise use null.
  metadata     = jsonencode(try(each.value.metadata, {}))   # Try if it exists, use it - otherwise empty. 
  parameters   = jsonencode(try(each.value.parameters, {})) # Try if it exists, use it - otherwise empty. 
  policy_rule  = jsonencode(each.value.policyRule)
}
