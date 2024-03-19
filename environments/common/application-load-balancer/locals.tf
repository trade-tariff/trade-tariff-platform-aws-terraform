locals {
  services = {
    admin = {
      host             = ["admin.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 11
    }

    signon = {
      host             = ["signon.*"]
      healthcheck_path = "/healthcheck/live"
      priority         = 12
    }

    hub_backend = {
      host             = ["hub.*"]
      paths            = ["/api/healthcheck"]
      healthcheck_path = "/api/healthcheckz"
      priority         = 13
    }

    hub_frontend = {
      host             = ["hub.*"]
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 14
    }

    backend_uk = {
      paths            = ["/uk/api/beta/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 15
    }

    backend_xi = {
      paths            = ["/xi/api/beta/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 16
    }

    duty_calculator = {
      paths            = ["/duty-calculator/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 17
    }

    search_query_parser = {
      paths            = ["/api/search/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 18
    }

    frontend = {
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 99 # Most generic rule for frontend should match last
    }
  }
}
