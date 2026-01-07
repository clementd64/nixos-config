variable "openbao_password" {
  sensitive = true
}

variable "miniflux_password" {
  sensitive = true
}

locals {
  databases = {
    openbao = {
      password         = var.openbao_password
      password_version = 1
    }
    miniflux = {
      password         = var.miniflux_password
      password_version = 1
    }
  }
}
