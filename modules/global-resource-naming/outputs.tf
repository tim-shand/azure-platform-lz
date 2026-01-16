output "full" {
  description = "Full length naming structure."
  value       = local.name_full
}

output "short" {
  description = "Short length naming structure (remove delimiter and condense length)."
  value       = local.name_short
}
