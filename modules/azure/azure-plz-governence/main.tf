#============================================#
# Platform LZ: Governance - Management Groups
#============================================#

# Create core top-level management group for the organization.
resource "azurerm_management_group" "mg_top_level" {
  display_name = "Core"
  name         = "${var.naming["prefix"]}-core-mg"
}

# Create child management groups.
resource "azurerm_management_group" "mg_platform" {
  for_each                      = var.plz_management_groups # Loop/repeat for each defined management group.
  display_name                  = each.value.mg_display_name # Get from objects.
  name                          = "${var.naming["prefix"]}-${each.key}-mg" # Use key title in naming. 
  parent_management_group_id    = azurerm_management_group.mg_top_level.id
  # Dirty way to assign PLZ subs, passed in via GH workflow.
  subscription_ids              = each.key == "platform" ? var.subscription_ids_plz : null
}
