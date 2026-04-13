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

data "azurerm_management_group" "platform" {
  name = "my-management-group-id"
}

# ------------------------------------------------------------- #

# ENTRA ID: Groups
data "azuread_user" "group_owners_adm" {
  for_each    = var.entra_groups_admins
  employee_id = each.value.owner_employee_id
}

