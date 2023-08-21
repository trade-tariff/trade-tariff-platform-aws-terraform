locals {
  environment = "development"
  services = {
    admin = {
      target_group_name = "trade-tariff-ad-tg-${local.environment}"
      host              = ["admin.*"]
      healthcheck_path  = "/healthcheckz"
    }

    signon = {
      target_group_name = "trade-tariff-so-tg-${local.environment}"
      host              = ["signon.*"]
      healthcheck_path  = "/healthcheck/live"
    }

    backend_uk = {
      target_group_name = "backend-uk-tg-${local.environment}"
      paths             = ["/uk/api/beta/*"]
      healthcheck_path  = "/healthcheckz"
    }

    backend_xi = {
      target_group_name = "backend-xi-tg-${local.environment}"
      paths             = ["/xi/api/beta/*"]
      healthcheck_path  = "/healthcheckz"
    }

    duty_calculator = {
      target_group_name = "trade-tariff-dc-tg-${local.environment}"
      paths             = ["/duty-calculator/*"]
      healthcheck_path  = "/healthcheckz"
    }

    search_query_parser = {
      target_group_name = "trade-tariff-sqp-tg-${local.environment}"
      paths             = ["/api/search/*"]
      healthcheck_path  = "/healthcheckz"
    }

    frontend = {
      target_group_name = "trade-tariff-fe-tg-${local.environment}"
      paths             = ["/*"]
      healthcheck_path  = "/healthcheckz"
    }
  }


  blue = {
    for k, v in local.services : "${k}_blue" => {
      target_group_name = "${k}_blue"
      host              = try(v.host, null)
      paths             = try(v.paths, null)
      healthcheck_path  = v.healthcheck_path
    }
  }

  green = {
    for k, v in local.services : "${k}_green" => {
      target_group_name = "${k}_green"
      host              = try(v.host, null)
      paths             = try(v.paths, null)
      healthcheck_path  = v.healthcheck_path
    }
  }

  # TODO: remove original target groups once blue and green are in use in all apps.
  blue_green = merge(local.services, local.blue, local.green)
}
