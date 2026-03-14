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

  validity_period_hours = 8760 # 1 year

  dns_names = [
    "backend-uk",
    "backend-xi",
    "backend-uk.tariff.internal",
    "backend-xi.tariff.internal",
  ]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
