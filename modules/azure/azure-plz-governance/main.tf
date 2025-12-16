#=====================================================#
# Platform LZ: Governance (Management Groups & Policy)
#=====================================================#

# Create core top-level management group for the organization.
resource "azurerm_management_group" "plz_governance" {
  display_name = "Core"
  name         = "${var.naming["prefix"]}-core-mg"
}

# Create child management groups.
resource "azurerm_management_group" "mg_platform" {
  for_each                   = var.gov_management_group_list            # Loop/repeat for each defined management group.
  display_name               = each.value.mg_display_name               # Get from objects.
  name                       = "${var.naming["prefix"]}-${each.key}-mg" # Use key title in naming. 
  parent_management_group_id = azurerm_management_group.mg_top_level.id
  # Dirty way to assign PLZ subs, passed in via GH workflow.
  subscription_ids = each.key == "platform" ? var.subscription_ids_plz : null
}
