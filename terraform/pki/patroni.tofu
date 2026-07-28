# CA

resource "tls_private_key" "patroni_ca" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "patroni_ca" {
  private_key_pem = tls_private_key.patroni_ca.private_key_pem

  subject {
    common_name  = "Patroni REST API"
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "patroni_ca" {
  cert_request_pem   = tls_cert_request.patroni_ca.cert_request_pem
  ca_private_key_pem = tls_private_key.root.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root.cert_pem

  is_ca_certificate     = true
  validity_period_hours = 10 * 365 * 24

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

locals {
  patroni_ca_bundle = join("", [
    tls_locally_signed_cert.patroni_ca.cert_pem,
    tls_self_signed_cert.root.cert_pem,
  ])
}

# Members

resource "tls_private_key" "patroni_member" {
  for_each  = local.etcd_servers
  algorithm = "ED25519"
}

resource "tls_cert_request" "patroni_member" {
  for_each = local.etcd_servers

  private_key_pem = tls_private_key.patroni_member[each.key].private_key_pem
  dns_names       = [each.value.dns_name]

  subject {
    common_name  = each.value.dns_name
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "patroni_member" {
  for_each = local.etcd_servers

  cert_request_pem   = tls_cert_request.patroni_member[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.patroni_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.patroni_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

# Administrator

resource "tls_private_key" "patroni_admin" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "patroni_admin" {
  private_key_pem = tls_private_key.patroni_admin.private_key_pem

  subject {
    common_name  = "patroni-admin"
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "patroni_admin" {
  cert_request_pem   = tls_cert_request.patroni_admin.cert_request_pem
  ca_private_key_pem = tls_private_key.patroni_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.patroni_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "client_auth",
  ]
}
