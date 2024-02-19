locals {
  applications = {
    "admin" = {
      lifecycle_policy = true
    },
    "backend" = {
      lifecycle_policy = true
    },
    "database-backups" = {
      lifecycle_policy = false
    },
    "duty-calculator" = {
      lifecycle_policy = true
    },
    "fpo-search" = {
      lifecycle_policy = false
    },
    "frontend" = {
      lifecycle_policy = true
    },
    "search-query-parser" = {
      lifecycle_policy = true
    },
    "signon" = {
      lifecycle_policy = true
    }
  }
}
