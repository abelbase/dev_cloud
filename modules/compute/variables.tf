variable "public_ip" {
  type = object({
    name              = string
    allocation_method = optional(string, "Static")
  })
}
variable "vm_name" {
  type = string
}
variable "nic_details" {
  type = object({
    name           = string
    ip_config_name = string
  })
}
variable "subnet_id" {
  type = string
}
variable "rg" {
  type = string
}
variable "location" {
  type = string
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

variable "tags" {
  type = object({
    dept = string
    team = string
    env  = string
  })
}
variable "pub_key" {
  type = string
}