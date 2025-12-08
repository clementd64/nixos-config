ui = true

storage "postgresql" {
  max_idle_connections = 0
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/app/origin-cert.pem"
  tls_key_file  = "/app/origin-key.pem"
}

seal "kmip" {
  endpoint    = "eu-west-gra.okms.ovh.net:5696"
  client_cert = "/app/client-cert.pem"
  client_key  = "/app/client-key.pem"
}
