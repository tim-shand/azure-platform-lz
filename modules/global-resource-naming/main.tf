#=====================================================#
# Module: Global - Resource Naming
#=====================================================#

# EXAMPLE:
# {org_prefix}-{project}-{category_1}-{category_2}-{environment}-{resource}
# Full: abc-platform-con-hub-plz
# Short: abcplatformgovlogplz

locals {
  short_length  = 24  # Maximum length for short names. 
  random_length = 6   # Length of random generated string. 
  delimiter     = "-" # Used to break up name sections. 

  # Construct name sections, populate with nothing if no value provided, remove unwanted characters and append delimter. 
  org_prefix  = var.org_prefix != null ? "${lower(replace(var.org_prefix, "/[^a-z0-9]/", ""))}" : ""
  project     = var.project != null ? "${local.delimiter}${lower(replace(var.project, "/[^a-z0-9]/", ""))}" : ""
  category1   = var.category1 != null ? "${local.delimiter}${lower(replace(var.category1, "/[^a-z0-9]/", ""))}" : ""
  category2   = var.category2 != null ? "${local.delimiter}${lower(replace(var.category2, "/[^a-z0-9]/", ""))}" : ""
  environment = var.environment != null ? "${local.delimiter}${lower(replace(var.environment, "/[^a-z0-9]/", ""))}" : ""

  # Construct full length naming structure. 
  name_full = "${local.org_prefix}${local.project}${local.category1}${local.category2}${local.environment}"

  # Construct short length naming structure (remove delimiter and condense length).
  short      = replace(local.name_full, "-", "")
  name_short = length(local.short) > local.short_length ? "${substr("${local.short}", 0, local.short_length - local.random_length)}" : "${local.short}"
}
