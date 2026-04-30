output "mg_subscriptions" {
  value = merge(
    local.management_group_subscriptions_level1,
    local.management_group_subscriptions_level2,
    local.management_group_subscriptions_level3
  )
}

output "policy_definitions" {
  description = "Map of custom policy definitions."
  value = {
    for k, v in azurerm_policy_definition.custom :
    k => {
      display_name = v.display_name
    }
  }
}

output "policy_initiatives" {
  description = "Map of custom policy initiatives."
  value = {
    for k, v in azurerm_management_group_policy_set_definition.custom :
    k => {
      display_name = v.display_name
      name         = v.name
      policies = [
        for value in v.policy_definition_reference : value.reference_id
      ]
    }
  }
}

output "policy_initiative_assignments" {
  description = "Map of policy initiative assignments to Management Groups."
  value = {
    for k, v in azurerm_management_group_policy_assignment.custom :
    k => {
      name                = v.name
      display_name        = v.display_name
      enforce             = v.enforce
      identity            = v.identity
      management_group_id = v.management_group_id
      parameters          = try(v.parameters, null)
    }
  }
}

output "policy_managed_identity" {
  description = "Map of policy managed identity resource."
  value = {
    principal_id        = azurerm_user_assigned_identity.policy.principal_id
    name                = azurerm_user_assigned_identity.policy.name
    resource_group_name = azurerm_user_assigned_identity.policy.resource_group_name
    location            = azurerm_user_assigned_identity.policy.location
  }
}
