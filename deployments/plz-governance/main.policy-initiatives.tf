#====================================================================================#
# Governance: Policy Initiatives
# Description: 
# - Build policy initiatives from mapped definitions. 
# - Deploy these once, at the root MG level. 
#====================================================================================#

locals {
  initiative_files_path = "${path.module}/policy_initiatives"                 # Supply path to JSON files. 
  initiative_files      = fileset("${local.initiative_files_path}", "*.json") # Decode all JSON initiative files and add metadata.
  initiatives = {
    for file_name in local.initiative_files :     # Loop each file in the list of files. 
    trimsuffix(file_name, ".json") => jsondecode( # Create map using trimmed file name as key, parsed JSON as value. 
    file("${local.initiative_files_path}/${file_name}")).properties
  }
}

# Policy: Initiatives - Add mapped definitions to each initiative.
resource "azurerm_management_group_policy_set_definition" "custom" {
  for_each            = local.initiatives # Local map variable of initiative names and content.
  name                = each.key          # Use trimmed filename as policy definition name.
  display_name        = "[${upper(var.stack.naming.workload_code)}] - Initiative - ${each.value.displayName}"
  description         = try(each.value.description, null)
  policy_type         = "Custom"
  management_group_id = local.management_groups_all_created.core.id # Create at core MG for use with all subs and MGs.
  parameters          = jsonencode(try(each.value.parameters, {}))  # Try if it exists, use it - otherwise use empty.
  metadata            = jsonencode(try(each.value.metadata, {}))    # Try if it exists, use it - otherwise use empty.
  dynamic "policy_definition_reference" {
    for_each = each.value.policyDefinitions # Generate dynamic object for each policy definition added in initiative.
    content {
      policy_definition_id = replace(
        policy_definition_reference.value.policyDefinitionId, "PLACEHOLDER", "${local.management_groups_all_created.core.name}"
      )
      reference_id       = policy_definition_reference.value.policyDefinitionReferenceId
      parameter_values   = jsonencode(try(policy_definition_reference.value.parameters, {}))
      policy_group_names = try(policy_definition_reference.value.groupNames, null)
    }
  }
  depends_on = [
    azurerm_policy_definition.custom # Must be created first before initiative can be created. 
  ]
}
