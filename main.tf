terraform {
  backend "azurerm" {
    storage_account_name = "tfstatestracc"
    container_name       = "envtfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.71.0"
    }
  }
}

provider "azurerm" {
  features {
      key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name_aks
  location = "West Europe"

  tags = var.tags
}

resource "azurerm_user_assigned_identity" "agw" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "hub-agw1-msi"
  tags                = var.tags
}

data "azuread_group" "aks_cluster_admins" {
  display_name = "AKS-cls-admins"
}

module "vnet" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  vnet_name           = var.vnet_name

  nsg_ids = {
    k8scls = azurerm_network_security_group.k8s.id
  }


  tags = var.tags
  depends_on = [azurerm_resource_group.example]
}

resource "azurerm_network_security_group" "k8s" {
  name                = "K8s"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  security_rule {
    name                       = "K8s ALLOW"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.allowed_public_ip
    destination_address_prefix = "*"
  }

  tags = var.tags
  
  depends_on = [azurerm_resource_group.example]
}


module "aks" {
  source                           = "./modules/k8s"
  resource_group_name              = azurerm_resource_group.example.name
  location                         = azurerm_resource_group.example.location
  kubernetes_version               = "1.20.7"
  orchestrator_version             = "1.20.7"
  prefix                           = "k8s"
  cluster_name                     = "K8s-cls"
  network_plugin                   = "azure"
  vnet_subnet_id                   = module.vnet.vnet_subnets[0]
  os_disk_size_gb                  = 50
  sku_tier                         = "Free" # defaults to Free
  enable_role_based_access_control = true
  rbac_aad_admin_group_object_ids  = [data.azuread_group.aks_cluster_admins.id]
  rbac_aad_managed                 = true
  private_cluster_enabled          = false # default value
  enable_http_application_routing  = true
  enable_azure_policy              = true
  enable_auto_scaling              = true
  agents_min_count                 = 1
  agents_max_count                 = 2
  agents_count                     = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 100
  agents_pool_name                 = "exnodepool"
  agents_type                      = "VirtualMachineScaleSets"
  agents_size                      = "Standard_B2s"
  waf_identity_id                  = azurerm_user_assigned_identity.agw.id
  waf_client_id                   = azurerm_user_assigned_identity.agw.client_id
  waf_principal_id                  = azurerm_user_assigned_identity.agw.principal_id
  agents_labels = {
    "nodepool" : "defaultnodepoolnew"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagentnew"
  }




  network_policy                 = "azure"
  #net_profile_dns_service_ip     = "10.2.1.10"
  #net_profile_docker_bridge_cidr = "170.10.0.1/16"
  #net_profile_service_cidr       = "10.0.0.0/16"
  # waf_id                         = module.web_application_firewall.waf_id
  depends_on = [module.vnet,azurerm_user_assigned_identity.agw]#, module.web_application_firewall]
}


module "web_application_firewall" {
     source = "./modules/waf"

      resource_group_name  = azurerm_resource_group.example.name
      location             = azurerm_resource_group.example.location

      custom_name             = "waf01"
      appgw_private_ip        = "10.0.1.10"
      appgw_private_subnet_id = module.vnet.vnet_subnets[1]
      pip1_name               = "waf-pip1"
      wafmsi_id = azurerm_user_assigned_identity.agw.id
      tags = var.tags
      
      depends_on = [module.vnet, time_sleep.wait_60_seconds]

}


resource "time_sleep" "wait_60_seconds" {
  

  create_duration = "60s"
}