resource "tls_private_key" "ecs_tls" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ecs_tls" {
  private_key_pem = tls_private_key.ecs_tls.private_key_pem

  subject {
    common_name  = "tariff.internal"
    organization = "trade-tariff"
  }

  validity_period_hours = 87600 # 10 years

  dns_names = [
    "*.tariff.internal",
  ]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
