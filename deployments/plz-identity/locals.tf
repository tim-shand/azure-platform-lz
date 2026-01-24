locals {
  tags_merged = merge(var.global.tags, var.tags)
}
