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

# Set postgres as child of all roles. Allow database administration
resource "postgresql_grant_role" "grant_postgres" {
  for_each          = local.databases
  role              = "postgres"
  grant_role        = each.key
  with_admin_option = true
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
