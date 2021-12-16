variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = ["10.33.0.0.0/16"]
}



variable "subnet_prefixes" {
  type        = list(string)
  description = "The address prefix to use for the subnet."
  default     = ["10.33.0.0/24", "10.33.1.0/24"]
}

variable "subnet_names" {
  type        = list(string)
  description = "A list of public subnets inside the vNet."
  default     = ["k8scls","waf01"]
}


variable "vnet_name" {
  description = "Vnet name"
  default = "vnet"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
      course = "Azure"
  }
}




variable "pip1_name" {
  description = "public Ip 1 name"
  default = "pip1"
}



variable "azurerm_log_analytics_workspace_name" {
  description = "local gw vpn ip"
  default = "logws"
}


variable "roletype" {
  description = "The tags to associate with your network and subnets."


  default = "Contributor"
}

variable "resource_group_name_aks" {
     description = "default resource group"
     default = "aks-agic-rg"
}

 variable "allowed_public_ip" {}
