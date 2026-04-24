# # Already set when MDFC is enabled previously - run import.
# import {
#   for_each = local.active_subscriptions
#   id       = "/subscriptions/${each.key}/providers/Microsoft.Security/workspaceSettings/default"
#   to       = azurerm_security_center_workspace.mgt[each.key]
# }
