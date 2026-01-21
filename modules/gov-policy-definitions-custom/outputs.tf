output "policies" {
  description = "List of custom policy definitions."
  value = {
    for k, p in azurerm_policy_definition.custom :
    k => {
      name = p.name
      id   = p.id
    }
  }
}
