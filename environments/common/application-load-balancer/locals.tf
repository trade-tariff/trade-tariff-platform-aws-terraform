locals {
  services = {
    admin = {
      priority         = 10
      host             = ["admin.*"]
      healthcheck_path = "/healthcheckz"
    }

    signon = {
      priority         = 20
      host             = ["signon.*"]
      healthcheck_path = "/healthcheck/live"
    }

    backend_uk = {
      priority         = 30
      paths            = ["/uk/api/beta/*"]
      healthcheck_path = "/healthcheckz"
    }

    backend_xi = {
      priority         = 35
      paths            = ["/xi/api/beta/*"]
      healthcheck_path = "/healthcheckz"
    }

    duty_calculator = {
      priority         = 40
      paths            = ["/duty-calculator/*"]
      healthcheck_path = "/healthcheckz"
    }

    search_query_parser = {
      priority         = 50
      paths            = ["/api/search/*"]
      healthcheck_path = "/healthcheckz"
    }

    # frontend is a fallback, so must have the highest priority
    frontend = {
      priority         = 100
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
    }
  }


  blue = {
    for k, v in local.services : "${k}_blue" => {
      priority         = v.priority + 5
      host             = try(v.host, null)
      paths            = try(v.paths, null)
      healthcheck_path = v.healthcheck_path
    }
  }

  green = {
    for k, v in local.services : "${k}_green" => {
      priority         = v.priority + 5
      host             = try(v.host, null)
      paths            = try(v.paths, null)
      healthcheck_path = v.healthcheck_path
    }
  }

  blue_green = merge(local.blue, local.green)
}
