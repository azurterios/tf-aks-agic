terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {
}



resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.region
  tags = var.tags
}

resource "azurerm_storage_account" "example" {
  name                     = var.state_str_acc_name
  resource_group_name      = var.resource_group_name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags

  depends_on = [azurerm_resource_group.example]
}

resource "azurerm_storage_container" "example" {
  name                  = "envtfstate"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"

  depends_on = [azurerm_storage_account.example]

}

resource "azurerm_role_assignment" "storageblobowner" {
  scope         = azurerm_storage_account.example.id
  principal_id  = data.azurerm_client_config.current.object_id
  role_definition_name = "Storage Blob Data Owner"
  
  depends_on = [azurerm_storage_account.example]
}