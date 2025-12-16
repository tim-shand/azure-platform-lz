#=====================================================#
# Platform LZ: Governance (Management Groups & Policy)
#=====================================================#

# Governance: Management Groups -----------------#

data "azurerm_subscriptions" "all" {} # Get all subscriptions visible to current user or Service Principal. 

locals {
  # NOTE: Requires subscriptions to be renamed prior to deployment to include 'subcription_identifier' string value from variables file. 
  mg_subscription_ids = {
    for mg_key, mg in var.gov_management_group_list : # Loop each key and its value set in the Management Group map of objects. 
    mg_key => distinct(concat(
      mg.subscription_identifier != null ? # If 'subscription_identifier' is not null, get subscriptions that contain the identifier string value. 
      [
        for sub in data.azurerm_subscriptions.all.subscriptions : # Loop each subscription (from all) and get ID where display name matches identifier.  
        sub.subscription_id                                       # Select the subscription ID if regex condition passed (find identifier string inside display name). 
        if can(regex(lower(mg.subscription_identifier), lower(sub.display_name)))
      ] : [] # Else, set as empty list if not matching subscriptions. 
    ))
  }
}

# Create top-level management group for the organization.
resource "azurerm_management_group" "plz_governance_mg_root" {
  name         = lower("${var.naming["org"]}-${var.gov_management_group_root}-mg") # Force lower-case for resource name.
  display_name = var.gov_management_group_root                                     # Display name is purely cosmetic. 
}

# Create child management groups under root management group.
resource "azurerm_management_group" "plz_governance_mg" {
  for_each                   = var.gov_management_group_list                      # Loop for each defined management group in variable. 
  name                       = lower("${var.naming["org"]}-${each.key}-mg")       # Use key title in naming.
  display_name               = each.value.display_name                            # Get from each object looped. 
  parent_management_group_id = azurerm_management_group.plz_governance_mg_root.id # Nest MGs under root management group. 
  subscription_ids           = local.mg_subscription_ids[each.key]                # Associate subscriptions based on identifier matching. 
}
