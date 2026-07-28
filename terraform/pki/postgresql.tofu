# CA

resource "tls_private_key" "postgresql_ca" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "postgresql_ca" {
  private_key_pem = tls_private_key.postgresql_ca.private_key_pem

  subject {
    common_name  = "Patroni PostgreSQL"
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "postgresql_ca" {
  cert_request_pem   = tls_cert_request.postgresql_ca.cert_request_pem
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
  postgresql_ca_bundle = join("", [
    tls_locally_signed_cert.postgresql_ca.cert_pem,
    tls_self_signed_cert.root.cert_pem,
  ])
}

# Servers

resource "tls_private_key" "postgresql_server" {
  for_each  = local.etcd_servers
  algorithm = "ED25519"
}

resource "tls_cert_request" "postgresql_server" {
  for_each = local.etcd_servers

  private_key_pem = tls_private_key.postgresql_server[each.key].private_key_pem
  dns_names = [
    each.value.dns_name,
    "db.as212625.net",
  ]

  subject {
    common_name  = each.value.dns_name
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "postgresql_server" {
  for_each = local.etcd_servers

  cert_request_pem   = tls_cert_request.postgresql_server[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.postgresql_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.postgresql_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "server_auth",
  ]
}

# Patroni PostgreSQL clients

resource "tls_private_key" "postgresql_patroni" {
  for_each  = local.etcd_servers
  algorithm = "ED25519"
}

resource "tls_cert_request" "postgresql_patroni" {
  for_each = local.etcd_servers

  private_key_pem = tls_private_key.postgresql_patroni[each.key].private_key_pem

  subject {
    common_name  = each.value.dns_name
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "postgresql_patroni" {
  for_each = local.etcd_servers

  cert_request_pem   = tls_cert_request.postgresql_patroni[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.postgresql_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.postgresql_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "client_auth",
  ]
}

# Administrator

resource "tls_private_key" "postgresql_admin" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "postgresql_admin" {
  private_key_pem = tls_private_key.postgresql_admin.private_key_pem

  subject {
    common_name  = "postgres"
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "postgresql_admin" {
  cert_request_pem   = tls_cert_request.postgresql_admin.cert_request_pem
  ca_private_key_pem = tls_private_key.postgresql_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.postgresql_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "client_auth",
  ]
}
