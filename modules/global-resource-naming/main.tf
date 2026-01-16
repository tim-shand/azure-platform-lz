#=====================================================#
# Module: Global - Resource Naming
#=====================================================#

# EXAMPLE:
# {org_prefix}-{project}-{?_category_1}-{?_category_2}-{environment}
# Full: abc-platform-con-hub-plz
# Short: abcplatformgovlogplz

locals {
  short_length  = 24  # Maximum length for short names. 
  random_length = 6   # Length of random generated string. 
  delimiter     = "-" # Used to break up name sections. 

  # Construct name sections, populate with nothing if no value provided, remove unwanted characters and append delimter. 
  org_prefix  = length(var.org_prefix) > 0 ? "${lower(replace("${var.org_prefix}", "/[^a-z0-9]/", ""))}${local.delimiter}" : ""
  project     = length(var.project) > 0 ? "${lower(replace("${var.project}", "/[^a-z0-9]/", ""))}${local.delimiter}" : ""
  category1   = length(var.category1) > 0 ? "${lower(replace("${var.category1}", "/[^a-z0-9]/", ""))}${local.delimiter}" : ""
  category2   = length(var.category2) > 0 ? "${lower(replace("${var.category2}", "/[^a-z0-9]/", ""))}${local.delimiter}" : ""
  environment = length(var.environment) > 0 ? "${lower(replace("${var.environment}", "/[^a-z0-9]/", ""))}" : ""

  # Construct full length naming structure. 
  name_full = "${local.org_prefix}${local.project}${local.category1}${local.category2}${local.environment}"

  # Construct short length naming structure (remove delimiter and condense length).
  short      = replace(local.name_full, "-", "")
  name_short = length(local.short) > local.short_length ? "${substr("${local.short}", 0, local.short_length - local.random_length)}" : "${local.short}"
}

