#=====================================================#
# Platform LZ: Governance - Policy Custom Initiatives
#=====================================================#

resource "azurerm_policy_set_definition" "custom" {
  for_each     = var.policy_groups
  name         = "${upper(each.key)}_initiative"
  display_name = "[${upper(var.stack_code)}] ${title(each.key)} Initiative" # Title case. 
  policy_type  = "Custom"
  #parameters   = {}
  policy_definition_reference {
    policy_definition_id = each.value.id
  }
}

### FUCK - have to do all again :(

# https://chatgpt.com/c/695db6b7-bb28-8321-b86d-21a8f34360ea
