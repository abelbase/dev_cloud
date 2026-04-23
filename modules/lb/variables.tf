variable "public_ip" {
  type        = string
  description = "public ip name for lb"
}
variable "rg" {
  type        = string
  description = "resource group name"
}
variable "location" {
  type        = string
  description = "location name"
}
variable "allocation_method" {
  type        = string
  default     = "Static"
  description = "Allocation method for IP"
}

variable "lb_name" {
  type        = string
  description = "name of lb"
}
variable "lb_ip_config" {
  type        = string
  description = "lb ip config name "
}
variable "tags" {
  type = object({
    dept = string
    team = string
    env  = string
  })
}
variable "lb_backend_pool_name" {
  type        = map(map(string))
  description = "backend pool name"
  default     = {}
}
variable "lb_backend_pool_address_name" {
  type = map(object({
    name               = string
    virtual_network_id = string
    ip_address         = string
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
    protocol = string
  }))
  default = null
}