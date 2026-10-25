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
    tls = {
      source  = "opentofu/tls"
      version = "~> 4.0"
    }
  }
}

resource "tls_private_key" "root" {
  algorithm = "ED25519"
}

resource "tls_self_signed_cert" "root" {
  private_key_pem = tls_private_key.root.private_key_pem

  is_ca_certificate     = true
  validity_period_hours = 10 * 365 * 24

  subject {
    common_name  = "AS212625 Root"
    organization = "AS212625"
  }

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}
