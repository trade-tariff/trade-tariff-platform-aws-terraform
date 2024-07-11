locals {
  services = {
    admin = {
      host             = ["admin.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 1
    }

    signon = {
      host             = ["signon.*"]
      healthcheck_path = "/healthcheck/live"
      priority         = 2
    }

    hub_backend = {
      host             = ["hub.*"]
      paths            = ["/api/healthcheck"]
      healthcheck_path = "/api/healthcheckz"
      priority         = 3
    }

    hub_frontend = {
      host             = ["hub.*"]
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 4
    }

    tea = {
      host             = ["tea.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 5
    }

    duty_calculator = {
      paths            = ["/duty-calculator/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 17
    }

    frontend_beta = {
      host             = ["beta.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 19
    }

    frontend = {
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 99 # Most generic rule for frontend should match last
    }
  }
}
