variable "region" {
    description =  "region name"
}



variable "resource_group_name" {
    description = "rg"
}

variable "state_str_acc_name" {
    description = "storage account"
}


variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
      course = "Azure"
  }
}