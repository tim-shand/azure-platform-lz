output "base_name" {
  description = "Base name including delimiter and environment"
  value       = local.base_name
}

output "full_name" {
  description = "Full name including delimiter and environment"
  value       = local.full_name
}

output "short_name" {
  description = "Short name with optional random string appended"
  value       = local.short_name
}

output "random_string" {
  description = "Output just the random string."
  value       = random_string.short_suffix.result
}
