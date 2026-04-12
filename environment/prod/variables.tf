variable "rg_location" {
  type = string
}
variable "rg_name" {
  type = string
}
variable "app_name" {
  type = string
}

variable "tags" {
  type = object({
    env          = string
    app_name     = string
    created_date = string
  })
}
variable "vnet_name" {
  type = string
}
variable "vnet_address" {
  type = list(string)
}
variable "subnet_details" {
  type = map(object({
    address_prefixes = optional(list(string), [])
  }))
  default = {}
}

variable "nsg_details" {
  type = map(object({
    nsg_name    = string
    subnet_name = string
    rule        = optional(map(map(string)), {})
  }))
  default = {}
}
variable "nic_details" {
  type = map(object({
    name    = string
    vm_name = string
    ip_config = object({
      name = string
    })
  }))
  default = {}
}
variable "public_ip" {
  type = map(object({
    name              = string
    allocation_method = optional(string, "Static")
  }))
}
variable "vm_name" {
  type = map(object({
    subnet_name = string
    is_public   = optional(bool, false)
    nic = object({
      name           = string
      ip_config_name = string

    })
  }))
}
variable "size" {
  type = string
  validation {
    condition     = can(regex("^Standard", var.size))
    error_message = "VM size should be standard only.."
  }
}
variable "username" {
  type = string
  validation {
    condition     = can(regex("^[a-zA-Z]+$", var.username))
    error_message = "only letters.."
  }
}
variable "public_ip_details" {
  type = map(object({
    name              = string
    allocation_method = optional(string, "Static")
  }))
  default = {}
}

variable "vault_name" {
  type = string
}
variable "vault_secret" {
  type = string
}
variable "vault_rg" {
  type = string
}
variable "vm_extension" {
  type = map(object({
    vm_name     = string
    script_name = string
  }))
}