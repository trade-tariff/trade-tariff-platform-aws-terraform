remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket  = "terraform-state-staging-451934005581"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }

  disable_init = tobool(get_env("DISABLE_INIT", false))
}
