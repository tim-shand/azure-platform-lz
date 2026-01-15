locals {
  prefix      = "${var.naming.prefix}-${var.naming.project}-${var.stack_code}" # Pre-configure resource naming. 
  tags_merged = merge(var.tags, { Stack = "${var.stack_name}" })
}
