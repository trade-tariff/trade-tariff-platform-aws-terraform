locals {
  services = {
    admin = {
      host             = ["admin.*"]
      healthcheck_path = "/healthcheckz"
    }

    signon = {
      host             = ["signon.*"]
      healthcheck_path = "/healthcheck/live"
    }

    hub_backend = {
      host             = ["hub.*"]
      paths            = ["/api/healthcheck"]
      healthcheck_path = "/api/healthcheckz"
    }

    hub_frontend = {
      host             = ["hub.*"]
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
    }

    backend_uk = {
      paths            = ["/uk/api/beta/*"]
      healthcheck_path = "/healthcheckz"
    }

    backend_xi = {
      paths            = ["/xi/api/beta/*"]
      healthcheck_path = "/healthcheckz"
    }

    duty_calculator = {
      paths            = ["/duty-calculator/*"]
      healthcheck_path = "/healthcheckz"
    }

    search_query_parser = {
      paths            = ["/api/search/*"]
      healthcheck_path = "/healthcheckz"
    }

    frontend = {
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
    }
  }
}
