resource "aws_ssm_parameter" "config" {
  for_each = var.parameters

  name  = "/${var.name_prefix}/${each.key}"
  type  = "String"
  value = each.value

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
  })
}
