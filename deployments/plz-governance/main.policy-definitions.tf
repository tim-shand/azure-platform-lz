#=====================================================#
# Platform LZ: Governance - Policy Definitions
#=====================================================#

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
