resource "tls_private_key" "ecs_tls" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ecs_tls" {
  private_key_pem = tls_private_key.ecs_tls.private_key_pem

  subject {
    common_name  = "ecs-tls-certificate"
    organization = "trade-tariff"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
