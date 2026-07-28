locals {
  etcd_servers = {
    siren = {
      dns_name = "siren.db.as212625.net"
    }
    aion = {
      dns_name = "aion.db.as212625.net"
    }
    ophion = {
      dns_name = "ophion.db.as212625.net"
    }
  }
}

# CA

resource "tls_private_key" "etcd_ca" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "etcd_ca" {
  private_key_pem = tls_private_key.etcd_ca.private_key_pem

  subject {
    common_name  = "etcd"
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "etcd_ca" {
  cert_request_pem   = tls_cert_request.etcd_ca.cert_request_pem
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

# peer (cluster)

resource "tls_private_key" "etcd_peer_ca" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "etcd_peer_ca" {
  private_key_pem = tls_private_key.etcd_peer_ca.private_key_pem

  subject {
    common_name  = "etcd peer"
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "etcd_peer_ca" {
  cert_request_pem   = tls_cert_request.etcd_peer_ca.cert_request_pem
  ca_private_key_pem = tls_private_key.etcd_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.etcd_ca.cert_pem

  is_ca_certificate     = true
  validity_period_hours = 5 * 365 * 24

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

locals {
  etcd_peer_ca_bundle = join("", [
    tls_locally_signed_cert.etcd_peer_ca.cert_pem,
    tls_locally_signed_cert.etcd_ca.cert_pem,
    tls_self_signed_cert.root.cert_pem,
  ])
}

resource "tls_private_key" "etcd_peer" {
  for_each  = local.etcd_servers
  algorithm = "ED25519"
}

resource "tls_cert_request" "etcd_peer" {
  for_each = local.etcd_servers

  private_key_pem = tls_private_key.etcd_peer[each.key].private_key_pem
  dns_names       = [each.value.dns_name]

  subject {
    common_name  = each.value.dns_name
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "etcd_peer" {
  for_each = local.etcd_servers

  cert_request_pem   = tls_cert_request.etcd_peer[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.etcd_peer_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.etcd_peer_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

# client/server

resource "tls_private_key" "etcd_client_server_ca" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "etcd_client_server_ca" {
  private_key_pem = tls_private_key.etcd_client_server_ca.private_key_pem

  subject {
    common_name  = "etcd client/server"
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "etcd_client_server_ca" {
  cert_request_pem   = tls_cert_request.etcd_client_server_ca.cert_request_pem
  ca_private_key_pem = tls_private_key.etcd_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.etcd_ca.cert_pem

  is_ca_certificate     = true
  validity_period_hours = 5 * 365 * 24

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

locals {
  etcd_client_server_ca_bundle = join("", [
    tls_locally_signed_cert.etcd_client_server_ca.cert_pem,
    tls_locally_signed_cert.etcd_ca.cert_pem,
    tls_self_signed_cert.root.cert_pem,
  ])
}

resource "tls_private_key" "etcd_server" {
  for_each  = local.etcd_servers
  algorithm = "ED25519"
}

resource "tls_cert_request" "etcd_server" {
  for_each = local.etcd_servers

  private_key_pem = tls_private_key.etcd_server[each.key].private_key_pem
  dns_names       = [each.value.dns_name]

  subject {
    common_name  = each.value.dns_name
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "etcd_server" {
  for_each = local.etcd_servers

  cert_request_pem   = tls_cert_request.etcd_server[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.etcd_client_server_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.etcd_client_server_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "etcd_admin" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "etcd_admin" {
  private_key_pem = tls_private_key.etcd_admin.private_key_pem

  subject {
    common_name  = "etcd-admin"
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "etcd_admin" {
  cert_request_pem   = tls_cert_request.etcd_admin.cert_request_pem
  ca_private_key_pem = tls_private_key.etcd_client_server_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.etcd_client_server_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "client_auth",
  ]
}

# Patroni clients

resource "tls_private_key" "etcd_patroni" {
  for_each  = local.etcd_servers
  algorithm = "ED25519"
}

resource "tls_cert_request" "etcd_patroni" {
  for_each = local.etcd_servers

  private_key_pem = tls_private_key.etcd_patroni[each.key].private_key_pem

  subject {
    common_name  = "patroni@${each.value.dns_name}"
    organization = "AS212625"
  }
}

resource "tls_locally_signed_cert" "etcd_patroni" {
  for_each = local.etcd_servers

  cert_request_pem   = tls_cert_request.etcd_patroni[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.etcd_client_server_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.etcd_client_server_ca.cert_pem

  validity_period_hours = 365 * 24

  allowed_uses = [
    "digital_signature",
    "client_auth",
  ]
}
