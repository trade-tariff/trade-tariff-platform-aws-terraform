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
    "fpo-developer-hub-backend" = {
      lifecycle_policy = true
    }
    "fpo-developer-hub-frontend" = {
      lifecycle_policy = true
    }
    "frontend" = {
      lifecycle_policy = true
    },
    "search-query-parser" = {
      lifecycle_policy = true
    },
    "signon" = {
      lifecycle_policy = true
      rules_override = [{
        rulePriority = 1
        description  = "Keep 6 months of images."
        selection = {
          tagStatus   = "tagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 180
        }
        action = {
          type = "expire"
        }
      }]
    }
  }
}
