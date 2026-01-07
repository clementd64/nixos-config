terraform {
  required_version = ">= 1.11"

  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.26.0"
    }
  }
}

provider "postgresql" {
  database_username = "postgres"
}

resource "postgresql_role" "role" {
  for_each            = local.databases
  name                = each.key
  login               = true
  password_wo         = each.value.password
  password_wo_version = each.value.password_version
}

resource "postgresql_database" "database" {
  for_each = local.databases
  name     = each.key
  owner    = each.key
  lifecycle {
    prevent_destroy = true
  }
}

resource "postgresql_grant" "grant_rw" {
  for_each    = local.databases
  database    = each.key
  role        = each.key
  object_type = "table"
  schema      = "public"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_default_privileges" "grant_rw" {
  for_each    = local.databases
  database    = each.key
  role        = each.key
  owner       = each.key
  object_type = "table"
  schema      = "public"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}
