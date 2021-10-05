resource "azurerm_resource_group" "this" {
  location = var.resource_group.location
  name     = var.resource_group.name
}
/*

data "azurerm_resource_group" "this" {
  name=var.resource_group.name
}
*/

data "azurerm_virtual_network" "this" {
  for_each            = var.networksecuritygroup
  name                = each.value.vnet_name
  resource_group_name = azurerm_resource_group.this.name
}
data "azurerm_subnet" "this" {
  for_each             = var.networksecuritygroup
  name                 =each.value.subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = each.value.vnet_name
}
#==============================================
resource "azurerm_network_security_group" "this" {
  for_each = var.networksecuritygroup
  location = azurerm_resource_group.this.location
  name     = each.value.name

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      access                       = security_rule.value.access
      direction                    = security_rule.value.direction
      name                         = security_rule.value.name
      destination_address_prefix   = lookup(security_rule.value, "destination_address_prefix", null)
      destination_address_prefixes = lookup(security_rule.value, "destination_address_prefixes", null)
      source_address_prefix        = lookup(security_rule.value, "source_address_prefix", null)
      source_address_prefixes      = lookup(security_rule.value, "source_address_prefixes", null)
      source_port_range            = lookup(security_rule.value, "source_port_range", null)
      source_port_ranges           = lookup(security_rule.value, "source_port_ranges", null)
      destination_port_range       = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges      = lookup(security_rule.value, "destination_port_ranges", null)
      priority                     = security_rule.value.priority
      protocol                     = security_rule.value.protocol

    }
  }

  resource_group_name = azurerm_resource_group.this.name

}
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.networksecuritygroup
  network_security_group_id = azurerm_network_security_group.this[each.key].id
  subnet_id                 = data.azurerm_subnet.this[each.key].id
}

output "nsgs" {
  value= azurerm_network_security_group.this

}
output "subnets" {
  value = data.azurerm_subnet.this
}