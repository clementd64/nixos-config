locals {
  client_names = toset([
    "codex",
    "miniflux",
    "ntfy",
    "pocketid",
    "synapse",
  ])
}

# CA

resource "tls_private_key" "bluemarine_ca" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "bluemarine_ca" {
  private_key_pem = tls_private_key.bluemarine_ca.private_key_pem

  subject {
    common_name  = "Blue-Marine PostgreSQL"
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "bluemarine_ca" {
  cert_request_pem   = tls_cert_request.bluemarine_ca.cert_request_pem
  ca_private_key_pem = tls_private_key.root.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root.cert_pem

  is_ca_certificate     = true
  validity_period_hours = 5 * 365 * 24

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

locals {
  bluemarine_ca_bundle = join("", [
    tls_locally_signed_cert.bluemarine_ca.cert_pem,
    tls_self_signed_cert.root.cert_pem,
  ])
}

# Servers

resource "tls_private_key" "bluemarine_server" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "bluemarine_server" {
  private_key_pem = tls_private_key.bluemarine_server.private_key_pem
  dns_names = [
    "db.as212625.net",
  ]

  subject {
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "bluemarine_server" {
  cert_request_pem   = tls_cert_request.bluemarine_server.cert_request_pem
  ca_private_key_pem = tls_private_key.bluemarine_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.bluemarine_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "server_auth",
  ]
}

output "server" {
  value = {
    ca   = local.bluemarine_ca_bundle
    cert = tls_locally_signed_cert.bluemarine_server.cert_pem
    key  = tls_private_key.bluemarine_server.private_key_pem
  }
  sensitive = true
}

# Clients

resource "tls_private_key" "bluemarine_client" {
  for_each  = local.client_names
  algorithm = "ED25519"
}

resource "tls_cert_request" "bluemarine_client" {
  for_each = local.client_names

  private_key_pem = tls_private_key.bluemarine_client[each.key].private_key_pem

  subject {
    common_name  = each.value
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "bluemarine_client" {
  for_each = local.client_names

  cert_request_pem   = tls_cert_request.bluemarine_client[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.bluemarine_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.bluemarine_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "client_auth",
  ]
}

output "clients" {
  value = {
    for name in sort(tolist(local.client_names)) : name => {
      ca   = local.bluemarine_ca_bundle
      cert = tls_locally_signed_cert.bluemarine_client[name].cert_pem
      key  = tls_private_key.bluemarine_client[name].private_key_pem
    }
  }
  sensitive = true
}
