#======================================#
# Module: Static Web App - Variables
#======================================#

# Azure
variable "subscription_id" {
  description = "Subscription ID for the target resources."
  type        = string
}

variable "location" {
  description = "The Azure location to deploy resources into."
  type        = string
}

variable "naming" {
  description = "A map of naming parameters to use with resources."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "custom_domain_name" {
  description = "Custom domain name to use with DNS CNAME and Azure SWA."
  type        = string
}

# Cloudflare: https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
variable "cloudflare_config" {
  description = "Map of Cloudflare details required for deployment."
  type = map(string)
  sensitive = true # No output.
}

# Github
variable "github_config" {
  description = "Map of values for Github configuration."
  type = map(string)
}
