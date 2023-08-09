locals {
  services = {
    admin = {
      target_group_name = "trade-tariff-ad-tg-${var.environment}"
      priority          = 10
      host              = ["admin.*"]
      healthcheck_path  = "/healthcheckz"
    }

    signon = {
      target_group_name = "trade-tariff-so-tg-${var.environment}"
      priority          = 20
      host              = ["signon.*"]
      healthcheck_path  = "/healthcheck/live"
    }

    backend_uk = {
      target_group_name = "backend-uk-tg-${var.environment}"
      priority          = 30
      paths             = ["/uk/api/beta/*"]
      healthcheck_path  = "/healthcheckz"
    }

    backend_xi = {
      target_group_name = "backend-xi-tg-${var.environment}"
      priority          = 35
      paths             = ["/xi/api/beta/*"]
      healthcheck_path  = "/healthcheckz"
    }

    worker_uk = {
      target_group_name = "worker-uk-tg-${var.environment}"
      priority          = 55
      paths             = ["/uk/api/beta/*"]
      healthcheck_path  = "/healthcheckz"
    }

    worker_xi = {
      target_group_name = "worker-xi-tg-${var.environment}"
      priority          = 60
      paths             = ["/xi/api/beta/*"]
      healthcheck_path  = "/healthcheckz"
    }

    duty_calculator = {
      target_group_name = "trade-tariff-dc-tg-${var.environment}"
      priority          = 40
      paths             = ["/duty-calculator/*"]
      healthcheck_path  = "/healthcheckz"
    }

    search_query_parser = {
      target_group_name = "trade-tariff-sqp-tg-${var.environment}"
      priority          = 50
      paths             = ["/api/search/*"]
      healthcheck_path  = "/healthcheckz"
    }

    # frontend is a fallback, so must have the highest priority
    frontend = {
      target_group_name = "trade-tariff-fe-tg-${var.environment}"
      priority          = 100
      paths             = ["/*"]
      healthcheck_path  = "/healthcheckz"
    }
  }
}
