variable "resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "The location of all of the resources"
  type        = string
}

variable "vm_name" {
  description = "The name of the Azure Resource Group"
  type        = string
}

variable "admin_username" {
  description = "The name of the Azure Resource Group"
  type        = string
}

variable "admin_password" {
  description = "The password of the Admin user on the vm server"
  type        = string
}

variable "vm_size" {
  description = "The size of the vm server"
  type        = string
}

variable "environment" { 
  description = "The current enviornment"
  type        = string
}

variable "rg_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
}