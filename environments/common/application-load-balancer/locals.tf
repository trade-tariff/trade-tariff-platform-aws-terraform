locals {
  services = {
    admin = {
      target_group_name = "trade-tariff-ad-tg-${var.environment}"
      priority          = 50
      paths             = ["/admin/*"] # TODO: confirm routes
    }

    backend = {
      target_group_name = "trade-tariff-be-tg-${var.environment}"
      priority          = 10
      paths = [
        "/chapters/*",
        "/search/*",
        "/xi/search/*"
      ]
    }

    duty_calculator = {
      target_group_name = "trade-tariff-dc-tg-${var.environment}"
      priority          = 20
      paths             = ["/duty-calculator/*"]
    }

    frontend = {
      target_group_name = "trade-tariff-fe-tg-${var.environment}"
      priority          = 100
      paths             = ["/"]
    }


    search_query_parser = {
      target_group_name = "trade-tariff-sqp-tg-${var.environment}"
      priority          = 30
      paths             = ["/api/search/*"]
    }

    signon = {
      target_group_name = "trade-tariff-so-tg-${var.environment}"
      priority          = 40
      paths             = ["/signin-required", "/users/*"]
    }
  }
}
