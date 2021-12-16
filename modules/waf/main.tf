resource "azurerm_public_ip" "pip1" {
  name                = var.pip1_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  sku = "Standard"

}

locals {
  backend_address_pool_name      = "beap"
  frontend_port_name             = "feport"
  frontend_ip_configuration_name = "feip"
  http_setting_name              = "be-htst"
  listener_name                  = "httplstn"
  request_routing_rule_name      = "rqrt"
  redirect_configuration_name    = "rdrcfg"
}



resource "azurerm_application_gateway" "network" {
  name                = var.custom_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  lifecycle {
    #prevent_destroy = true
    ignore_changes = [
      backend_address_pool,
      http_listener,
      backend_http_settings,
      request_routing_rule,
      probe,
      tags
    ]
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.wafmsi_id]
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.appgw_private_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  # frontend_port {
  #   name = "httpsPort"
  #   port = 443
  # }

  frontend_ip_configuration {
   name                 = "waf-fe-pip"
   public_ip_address_id = azurerm_public_ip.pip1.id
  }

  frontend_ip_configuration {
      name                 = local.frontend_ip_configuration_name
      private_ip_address_allocation = "Static"
      private_ip_address            = var.appgw_private_ip
      subnet_id                     = var.appgw_private_subnet_id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = "waf-fe-pip"
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"

  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }



  tags = var.tags

  depends_on = [azurerm_public_ip.pip1]
}
