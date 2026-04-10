variable "rg_name" {
  type = string

}
variable "rg_location" {
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
    created_by   = optional(string,"terraform")
  })
}