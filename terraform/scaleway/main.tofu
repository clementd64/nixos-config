variable "passphrase" {
  type      = string
  sensitive = true
}

terraform {
  encryption {
    key_provider "pbkdf2" "sops" {
      passphrase = var.passphrase
    }
    method "aes_gcm" "crypto" {
      keys = key_provider.pbkdf2.sops
    }
    state {
      method   = method.aes_gcm.crypto
      enforced = true
    }
    plan {
      method   = method.aes_gcm.crypto
      enforced = true
    }
  }

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.79"
    }
  }
}

# siren

resource "scaleway_instance_ip" "siren" {
  zone = "fr-par-1"
  type = "routed_ipv6"
}

resource "scaleway_instance_volume" "siren-system" {
  name       = "siren-system"
  zone       = "fr-par-1"
  type       = "l_ssd"
  size_in_gb = 10
}

resource "scaleway_block_volume" "siren-pg" {
  name       = "siren-pg"
  zone       = "fr-par-1"
  size_in_gb = 10
  iops       = 5000
}

resource "scaleway_instance_server" "siren" {
  name  = "siren"
  zone  = "fr-par-1"
  type  = "STARDUST1-S"
  ip_id = scaleway_instance_ip.siren.id

  root_volume {
    volume_id = scaleway_instance_volume.siren-system.id
  }

  additional_volume_ids = [scaleway_block_volume.siren-pg.id]

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [image]
  }
}

# aion

resource "scaleway_instance_ip" "aion" {
  zone = "nl-ams-1"
  type = "routed_ipv6"
}

resource "scaleway_instance_volume" "aion-system" {
  name       = "aion-system"
  zone       = "nl-ams-1"
  type       = "l_ssd"
  size_in_gb = 10
}

resource "scaleway_block_volume" "aion-pg" {
  name       = "aion-pg"
  zone       = "nl-ams-1"
  size_in_gb = 10
  iops       = 5000
}

resource "scaleway_instance_server" "aion" {
  name  = "aion"
  zone  = "nl-ams-1"
  type  = "STARDUST1-S"
  ip_id = scaleway_instance_ip.aion.id

  root_volume {
    volume_id = scaleway_instance_volume.aion-system.id
  }

  additional_volume_ids = [scaleway_block_volume.aion-pg.id]

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [image]
  }
}

# ophion

resource "scaleway_instance_ip" "ophion" {
  zone = "pl-waw-2"
  type = "routed_ipv6"
}

resource "scaleway_instance_volume" "ophion-system" {
  name       = "ophion-system"
  zone       = "pl-waw-2"
  type       = "l_ssd"
  size_in_gb = 10
}

resource "scaleway_block_volume" "ophion-pg" {
  name       = "ophion-pg"
  zone       = "pl-waw-2"
  size_in_gb = 10
  iops       = 5000
}

resource "scaleway_instance_server" "ophion" {
  name  = "ophion"
  zone  = "pl-waw-2"
  type  = "STARDUST1-S"
  ip_id = scaleway_instance_ip.ophion.id

  root_volume {
    volume_id = scaleway_instance_volume.ophion-system.id
  }

  additional_volume_ids = [scaleway_block_volume.ophion-pg.id]

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [image]
  }
}
