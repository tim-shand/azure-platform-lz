output "initiatives" {
  description = "Output custom policy initiative names and IDs."
  value = {
    for k, i in azurerm_policy_set_definition.custom :
    k => i.id
  }
}
