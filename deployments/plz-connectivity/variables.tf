variable "subscription_id_iac" {
  description = "Subscription ID of the dedicated IaC subscription."
  type        = string
  nullable    = false
}

variable "subscription_id" {
  description = "Subscription ID for the stack resources."
  type        = string
  nullable    = false
}

variable "global" {
  description = "Map of global variables used across multiple deployment stacks."
  type        = map(map(string))
  nullable    = false
  default     = {}
}

variable "stack" {
  description = "Map of stack specific variables for use within current deployment."
  type        = map(map(string))
  nullable    = false
  default     = {}
}

variable "global_outputs" {
  description = "Map of Shared Service key names, used to get IDs and names in data calls."
  type        = map(map(string))
}

variable "global_outputs_name" {
  description = "Name of global outputs shared service App Configuration created during bootstrap."
  type        = string
}

variable "global_outputs_rg" {
  description = "Map of global outputs shared service Resource Group for App Configuration created during bootstrap."
  type        = string
}

# CONNECTIVITY: General
# ------------------------------------------------------------- #

variable "vnet_hub_cidr" {
  description = "List of address spaces for hub VNet."
  type        = list(string)
  nullable    = false
}

variable "hub_bastion" {
  description = "Object describing the Bastion configuration."
  type = object({
    enabled = bool
    subnet  = list(string)
    sku     = string # Standard required for 'Native client support'. 
  })
}

variable "hub_firewall" {
  description = "Object describing the Firewall configuration."
  type = object({
    enabled = bool
    subnet  = list(string)
  })
}

variable "hub_gateway" {
  description = "Object describing the VPN Gateway configuration."
  type = object({
    enabled = bool
    subnet  = list(string)
    type    = string
    sku     = string
  })
  validation {
    condition     = contains(["Vpn", "ExpressRoute"], var.hub_gateway.type)
    error_message = "One of 'Vpn' or 'ExpressRoute' must be provided."
  }
}
