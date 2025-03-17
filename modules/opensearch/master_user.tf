resource "random_string" "master_user_username" {
  count   = var.create_master_user ? 1 : 0
  length  = 8
  numeric = true
  special = false
}

resource "random_password" "master_user_password" {
  count = var.create_master_user ? 1 : 0

  length  = 16
  numeric = true
  special = true

  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1

  override_special = "!_$"
}
