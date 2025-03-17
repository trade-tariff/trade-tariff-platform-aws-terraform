locals {
  master_user_username = var.create_master_user ? random_string.master_user_username[0].result : var.master_user_username
  master_user_password = var.create_master_user ? random_password.master_user_password[0].result : var.master_user_password
}
