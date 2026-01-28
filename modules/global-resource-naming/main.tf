#==================================================================#
# Module: global-resource-naming
# Description: 
# - Provides a universal naming structure using an opinioned format. 
# - Ensures consistent naming for project resources. 
#==================================================================#

locals {
  # Combine base segments. 
  base_segments = compact([ # Filters a list, removing null or empty string elements. Returns new list containing only non-empty/null elements.
    var.prefix,
    var.workload,
    var.stack_or_env,
    var.category
  ])

  # Full name with dash separation. 
  full_name_base       = join("-", local.base_segments)                                                                         # Adds the dash separator between segments. 
  full_name_base_trunc = substr(local.full_name_base, 0, var.max_length_full - (var.ensure_unique ? var.random_length + 1 : 0)) # Truncates to max length for full names.
  full_name_suffix = (var.ensure_unique && length(random_string.suffix) > 0 ?                                                   # If unique is enabled, and random suffix > 0, combine. 
  "${local.full_name_base_trunc}-${random_string.suffix[0].result}" : local.full_name_base_trunc)                               # Else, just use full truncated name. 
  full_name        = lower(local.full_name_base_trunc)                                                                          # Full name with separators, truncated. 
  full_name_unique = lower(local.full_name_suffix)                                                                              # Full name plus random unique suffix. 

  # Compact name (no separator). 
  compact_base_raw   = join("", local.base_segments)                           # Combine segments with no separator. 
  compact_base_clean = lower(replace(local.compact_base_raw, "[^a-z0-9]", "")) # Remove non alpha-numeric characters. 

  # Truncate base for suffix if needed. 
  truncated_base_length  = (var.ensure_unique ? max(var.max_length_compact - var.random_length, 1) : var.max_length_compact)
  compact_base_truncated = substr(local.compact_base_clean, 0, local.truncated_base_length - 2)

  # Append suffix if needed. 
  compact_name_unique = (var.ensure_unique && length(random_string.suffix) > 0 ?                     # If unique is enabled, and random suffix > 0, combine.
  "${local.compact_base_truncated}${random_string.suffix[0].result}" : local.compact_base_truncated) # Else, just use compact truncated name. 
  compact_name = local.compact_base_truncated
}

# Random suffix generation. 
resource "random_string" "suffix" {
  count   = var.ensure_unique ? 1 : 0 # If unique is enabled. 
  length  = var.random_length         # Use default if not provided. 
  upper   = false
  lower   = false
  numeric = true
  special = false
}
