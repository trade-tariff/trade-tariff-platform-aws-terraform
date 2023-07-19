locals {
  services = {
    admin = {
      target_group_name = "trade-tariff-ad-tg-${var.environment}"
      priority          = 10
      host              = ["admin.*"]
    }

    signon = {
      target_group_name = "trade-tariff-so-tg-${var.environment}"
      priority          = 20
      host              = ["signon.*"]
    }

    backend_uk = {
      target_group_name = "backend-uk-tg-${var.environment}"
      priority          = 30
      paths             = ["/uk/api/beta/*"]
    }

    backend_xi = {
      target_group_name = "backend-xi-tg-${var.environment}"
      priority          = 35
      paths             = ["/xi/api/beta/*"]
    }

    duty_calculator = {
      target_group_name = "trade-tariff-dc-tg-${var.environment}"
      priority          = 40
      paths             = ["/duty-calculator/*"]
    }

    search_query_parser = {
      target_group_name = "trade-tariff-sqp-tg-${var.environment}"
      priority          = 50
      paths             = ["/api/search/*"]
    }

    # frontend is a fallback, so must have the highest priority
    frontend = {
      target_group_name = "trade-tariff-fe-tg-${var.environment}"
      priority          = 100
      paths             = ["/*"]
    }
  }
}
