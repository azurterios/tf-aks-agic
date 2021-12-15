variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = ["10.0.0.0/16"]
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  type        = list(string)
  description = "The DNS servers to be used with vNet."
  default     = ["8.8.8.8"]
}



variable "nsg_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = map(string)
  default = {
  
  }
}

variable "vnet_name" {
  description = "Vnet name"
  default = "vnet"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

}


variable "pip1_name" {
  description = "public Ip 1 name"
  default = "pip1"
}


variable "resource_group_name" {
  description = "resource group name"
  default = "rg"
}

variable "location" {
  description = "resource group location"
  default = "West Europe"
}

variable "appgw_private_ip" {
  description = "vpn gw connectionname"
  default = "nameconn"
}

variable "appgw_private_subnet_id" {
  description = "subnet id"
  default = "dfdsfkj"
}

variable "wafmsi_id" {
  description = "subnet id"
  default = "dfdsfkj"
}

variable "keyvault_secret_id" {
  description = "subnet id"
  default = "dfdsfkj"
}



variable "custom_name" {}