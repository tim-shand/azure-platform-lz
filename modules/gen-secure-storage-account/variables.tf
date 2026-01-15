variable "storage_account_name" {
  description = "Desired name for the new storage account."
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "Target Resource Group for the Storage Account to be created in."
  type        = string
  nullable    = false
}

variable "location" {
  description = "Location of Storage Account."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Map of key/value pairs containing tag names and values."
  type        = map(string)
  nullable    = false
}

variable "account_tier" {
  description = "Defines the tier to use for the storage account."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Valid values for account_tier are (Standard, Premium)."
  }
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account."
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Valid values for account_replication_type are (LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS)."
  }
}

variable "account_kind" {
  description = "Defines the kind of storage account."
  type        = string
  nullable    = false
  default     = "StorageV2"
  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "StorageV2"], var.account_kind)
    error_message = "Valid values for account_kind are (BlobStorage, BlockBlobStorage, FileStorage, StorageV2)."
  }
}
