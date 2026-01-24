# locals {
#   base_name = join( # Build base name from provided sections. 
#     var.delimiter, compact([
#       for s in var.sections : lower(replace(s, "/[^a-z0-9]/", "")) # Enforce lower-case, remove any non-alpha-numeric characters. 
#     ])
#   )
#   # Add environment section if provided, else just use base name. 
#   full_name = var.environment != null ? "${local.base_name}${var.delimiter}${lower(var.environment)}" : local.base_name

#   # Build the short base name, removing delimiter. 
#   short_base = replace(local.full_name, var.delimiter, "")

#   # Truncate short name if exceeds max length. 
#   truncated_short = (
#     length(local.short_base) > var.short_max_length - var.random_length ? # If
#     substr(local.short_base, 0, var.short_max_length - var.random_length) # Then
#     : local.short_base                                                    # Else
#   )

#   # Add the optional random string (if enabled). 
#   short_name = (
#     var.append_random && length(local.short_base) > var.short_max_length - var.random_length ? # If
#     "${local.truncated_short}-${random_string.short_suffix.result}"                            # Then
#     : local.truncated_short                                                                    # Else
#   )
# }

# # Generate the random string 
# resource "random_string" "short_suffix" {
#   length  = var.random_length
#   upper   = false
#   special = false
# }

locals {
  # Build base name from provided sections. 
  base_name = join(
    var.delimiter, compact([
      for s in var.sections : lower(replace(s, "/[^a-z0-9]/", "")) # enforce lower-case, remove non-alphanum. 
    ])
  )

  # Add environment section if provided
  full_name = var.environment != null ? "${local.base_name}${var.delimiter}${lower(var.environment)}" : local.base_name
  # Short base without delimiters
  short_base = replace(local.full_name, var.delimiter, "")
  # Compute max length for truncated base to fit random suffix
  max_base_length = var.short_max_length - var.random_length - 1 # -1 for optional delimiter
  # Truncate short name if it exceeds allowed length
  truncated_short = length(local.short_base) > local.max_base_length ? substr(local.short_base, 0, local.max_base_length) : local.short_base
  # Always append random string with delimiter
  short_name = "${local.truncated_short}-${random_string.short_suffix.result}"
}

# Generate random string. 
resource "random_string" "short_suffix" {
  length  = var.random_length
  upper   = false
  lower   = true
  numeric = true
  special = false
}
