variable "location" {
  description = "The Azure Region in which resources will be created."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group in which the infrastructure will be deployed."
  type        = string
  default     = "my-resource-group"
}

variable "vnet_cidr" {
  description = "CIDR block for the VNET."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "vm_count_per_subnet" {
  description = "Number of VM instances to create per subnet."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Size of the VM instances."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Username for the administrator account on the VMs."
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Password for the administrator account on the VMs."
  type        = string
}

