module "identity_cognito_app_client_count_monitor" {
  source = "../../../modules/cognito_app_client_count_monitor"

  environment   = var.environment
  user_pool_id  = module.identity_cognito.user_pool_id
  user_pool_arn = module.identity_cognito.user_pool_arn
  alarm_actions = local.alert_actions
}
