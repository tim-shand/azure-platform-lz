# GLOBAL / SHARED SERVICES
# ------------------------------------------------------------- #

# IaC: Get IaC subscription for aliased provider. 
data "azurerm_subscription" "iac_sub" {
  subscription_id = var.subscription_id_iac # Pass in the IaC subscription variable. 
}

data "terraform_remote_state" "governance" {
  backend = "azurerm"
  config = {
    resource_group_name  = "${var.remote_state_governance.resource_group}"
    storage_account_name = "${var.remote_state_governance.storage_account}"
    container_name       = "${var.remote_state_governance.blob_container}"
    key                  = "${var.remote_state_governance.state_key}"
  }
}

# MANAGEMENT: General
# ------------------------------------------------------------- #

# # Management Group: Core MG ID - used for Managed Identity RBAC scope. 
# data "azurerm_app_configuration_key" "mg_core_id" {
#   configuration_store_id = data.azurerm_app_configuration.iac.id
#   key                    = var.global_outputs.governance.core_mg_id
#   label                  = var.global_outputs.governance.label
# }
# data "azurerm_app_configuration_key" "mg_core_name" {
#   configuration_store_id = data.azurerm_app_configuration.iac.id
#   key                    = var.global_outputs.governance.core_mg_name
#   label                  = var.global_outputs.governance.label
# }

# # Policy Diagnostics (Platform) - Used for assignment after LAW deployment. 
# data "azurerm_app_configuration_key" "mg_platform_id" {
#   configuration_store_id = data.azurerm_app_configuration.iac.id
#   key                    = var.global_outputs.governance.platform_mg_id
#   label                  = var.global_outputs.governance.label
# }
# data "azurerm_app_configuration_key" "policy_mi_name" {
#   configuration_store_id = data.azurerm_app_configuration.iac.id
#   key                    = var.global_outputs.governance.policy_managed_idn_name
#   label                  = var.global_outputs.governance.label
# }
# data "azurerm_app_configuration_key" "policy_mi_rg" {
#   configuration_store_id = data.azurerm_app_configuration.iac.id
#   key                    = var.global_outputs.governance.policy_managed_idn_resource_group
#   label                  = var.global_outputs.governance.label
# }

# data "azurerm_app_configuration_key" "policy_diag_plz_name" {
#   configuration_store_id = data.azurerm_app_configuration.iac.id
#   key                    = var.global_outputs.governance.policy_diag_plz_name
#   label                  = var.global_outputs.governance.label
# }
# data "azurerm_policy_set_definition" "policy_diag_plz" {
#   name                  = data.azurerm_app_configuration_key.policy_diag_plz_name.value
#   management_group_name = data.azurerm_app_configuration_key.mg_core_name.value
# }
# data "azurerm_user_assigned_identity" "policy_mi" {
#   name                = data.azurerm_app_configuration_key.policy_mi_name.value
#   resource_group_name = data.azurerm_app_configuration_key.policy_mi_rg.value
# }

# MANAGEMENT: Subscriptions
# ------------------------------------------------------------- #

# # Subscription IDs (Platform)
# data "azurerm_app_configuration_key" "platform_subs" {
#   for_each               = var.global_outputs.subscriptions # Loop for each entry in subscription keys list. 
#   configuration_store_id = data.azurerm_app_configuration.iac.id
#   key                    = each.value
#   label                  = var.global_outputs.iac.label
# }

# # Subscriptions Details (Platform)
# data "azurerm_subscription" "platform_subs" {
#   for_each        = data.azurerm_app_configuration_key.platform_subs
#   subscription_id = each.value.value
# }

# ENTRA ID: Groups
# ------------------------------------------------------------- #

data "azuread_user" "group_owners_adm" {
  for_each    = var.entra_groups_admins
  employee_id = each.value.owner_employee_id
}
