variable "subscription_id" {
    description = "Azure Subscription ID"
}
variable "client_id" {
    description = "Azure Client ID"
}
variable "client_secret" {
    description = "Azure Client Secret"
}
variable "tenant_id" {
    description = "Azure Tenant ID"
}

variable "location" {
  default = "westeurope"
  description = "The Azure Region in which the resources in this example should exist"
}

variable "resourcegroup" {
  default = "rg_inlets"
  description = "The Azure Resource Group Name"
}

variable "inlets_authtoken" {
  description = "Inlets Server authentication token"
}

variable "vm_size" {
  default = "Standard_B1s"
  description = "The size of the VM"
}

variable "vm_hostname" {
  description = "Set the hostname. For example your companyname. No spaces, underscores, dashes or any special characters."
}

variable "admin_username" {
  description = "Set the admin username for the VM (must not be reserved words like admin, root, administrator)."
}

variable "admin_password" {
  description = "Set the password for the VM (minimum lenght: 6, must contain uppercase, digit and special character)."
}


variable "tags" {
  type        = map
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "inlets_server"
  }
}