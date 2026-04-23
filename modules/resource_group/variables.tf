variable "rg_name" {
  type = string

}
variable "rg_location" {
  type = string
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