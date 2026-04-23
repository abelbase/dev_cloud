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
    dept = string
    team = string
    env  = string
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

variable "public_ip_alb" {
  type        = string
  description = "public ip name for lb"
}

variable "lb_name" {
  type        = string
  description = "name of lb"
}
variable "lb_ip_config" {
  type        = string
  description = "lb ip config name "
}
variable "lb_backend_pool_name" {
  type        = map(map(string))
  description = "backend pool name"
  default     = {}
}
variable "lb_backend_pool_address_name" {
  type = map(object({
    name               = string
    virtual_network_id = optional(string)
    ip_address         = optional(string)
    backend_pool_name  = string
  }))
  description = "details of backend pool address"
  default     = null
}

variable "lb_rule" {
  type = map(object({
    name              = string
    protocol          = string
    frontend_port     = string
    backend_port      = string
    backend_pool_name = string
    health_probe_name = string

  }))
  default = null
}

variable "lb_probe" {
  type = map(object({
    name     = string
    port     = string
    protocol = optional(string, "Tcp")
  }))
  default = null
}

variable "subs_id" {
  type        = string
  description = "subscription id "
}

variable "aks_config" {
  type = object({
    aks_name            = optional(string, null)
    location            = optional(string, null)
    resource_group_name = optional(string, null)
    dns_prefix          = optional(string, null)
    default_node_pool   = optional(map(string), {})
  })
  default = {}
}
variable "acr_config" {
  type = object({
    name                = optional(string, null)
    resource_group_name = optional(string, null)
    location            = optional(string, null)
    sku                 = optional(string, "Standard")
    role_assingment     = optional(string, null)
  })
  default = null
}
