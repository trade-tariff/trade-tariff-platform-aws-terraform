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
    "database-replication" = {
      lifecycle_policy = false
    },
    "duty-calculator" = {
      lifecycle_policy = true
    },
    "fpo-search" = {
      lifecycle_policy = false
    },
    "fpo-developer-hub-backend" = {
      lifecycle_policy = true
    }
    "fpo-developer-hub-frontend" = {
      lifecycle_policy = true
    }
    "frontend" = {
      lifecycle_policy = true
    },
    "signon" = {
      lifecycle_policy = true
    },
    "terraform" = {
      lifecycle_policy = false
    },
    "tea" = {
      lifecycle_policy = true
    },
  }
}
