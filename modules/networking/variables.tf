variable "vnet_name" {
  type = string
}

variable "rg" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
  validation {
    condition     = alltrue([for ip in var.vnet_address_space : can(cidrhost(ip, 0))])
    error_message = "ip address not in format..."
  }
}

variable "tags" {
  type = object({
    dept         = string
    team         = string
    env          = string
    created_by   = string
    created_date = string
  })
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
    rule        = any
  }))
  default = {}
}