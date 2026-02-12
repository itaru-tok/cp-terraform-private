variable "zone_name" {
  type = string
}

variable "records" {
  type = list(object({
    name   = string
    type   = string
    values = optional(list(string))
    ttl    = optional(number)
    alias = optional(object({
      zone_id                = string
      name                   = string
      evaluate_target_health = bool
    }))
  }))
  default = []
}

variable "ses" {
  type = object({
    enable      = bool
    dkim_tokens = list(string)
  })
  default = {
    enable      = false
    dkim_tokens = []
  }
}
