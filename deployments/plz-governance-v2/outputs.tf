# output "subscriptions_all" {
#   value = data.azurerm_subscriptions.all.subscriptions
# }

# output "management_group_subscriptions" {
#   value = module.management-groups.management_group_subscriptions
# }

output "management_groups_subs_level1" {
  value = module.management-groups.management_groups_subs_level1
}
