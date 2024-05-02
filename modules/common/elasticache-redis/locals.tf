locals {
  tags = merge(
    {
      Project = "trade-tariff"
    },
    var.tags,
  )
}

resource "random_password" "auth_token" {
  length  = 16
  numeric = true
  special = true

  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1

  override_special = "@\"/"
}
