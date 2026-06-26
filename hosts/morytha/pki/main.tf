terraform {
  required_providers {
    tls = {
      source  = "opentofu/tls"
      version = "~> 4.0"
    }
  }
}


locals {
  client_names = toset([
    "miniflux",
  ])
}

resource "tls_private_key" "ca" {
  algorithm = "ED25519"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  is_ca_certificate     = true
  validity_period_hours = 10 * 365 * 24

  subject {
    common_name  = "morytha"
    organization = "morytha"
  }

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

output "ca_certificate_pem" {
  value = tls_self_signed_cert.ca.cert_pem
}

resource "tls_private_key" "server" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem
  dns_names       = []

  subject {
    common_name  = "morytha"
    organization = "morytha"
  }
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "server_auth",
  ]
}

output "server" {
  value = {
    cert = tls_locally_signed_cert.server.cert_pem
    key  = tls_private_key.server.private_key_pem
  }
  sensitive = true
}

resource "tls_private_key" "client" {
  for_each = local.client_names

  algorithm = "ED25519"
}

resource "tls_cert_request" "client" {
  for_each = local.client_names

  private_key_pem = tls_private_key.client[each.key].private_key_pem

  subject {
    common_name  = each.key
    organization = "morytha"
  }
}

resource "tls_locally_signed_cert" "client" {
  for_each = local.client_names

  cert_request_pem   = tls_cert_request.client[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "client_auth",
  ]
}

output "clients" {
  value = {
    for name in sort(tolist(local.client_names)) : name => {
      cert = tls_locally_signed_cert.client[name].cert_pem
      key  = tls_private_key.client[name].private_key_pem
    }
  }
  sensitive = true
}
