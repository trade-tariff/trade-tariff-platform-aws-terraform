locals {
  # We have a mixture of release-prefixed tagged images and untagged images.
  #
  # Untagged images are considered "development" images but this is not always the
  # case since some applications don't cut a release tag to identify a
  # deployment as released to production (e.g. for different classes of lambda or applications owned
  # by a different upstream).
  #
  # admin/backend/frontend are also continuously deployed (staging auto-deploys
  # on every merge to main, production auto-deploys on staging success), so
  # their production_images_to_keep is sized the same way as the other CD
  # apps below: high enough that a busy release day doesn't burn through the
  # whole retention window in a few hours.
  #
  # We have a higher number of development images to reflect the fact that there
  # can be a lot of concurrently built images across different branches and
  # developers aren't always incentivised to clean up after themselves and have
  # long-lived branches.
  #
  # The lifecycle policy is just a convenience to disable application lifecycles
  # in an emergency.
  #
  # Untagged images are dangling layers/manifests left behind by rebuilds
  # (e.g. a branch re-pushing "latest") -- they can only be referenced by
  # digest, not deployed, so pruning them by age is safe regardless of the
  # count-based rules below. This is a backstop against them accumulating
  # indefinitely between count-threshold breaches.
  untagged_image_expiry_days = 14

  applications = {
    # Continuous deployment applications (frontend-facing; production_images_to_keep
    # is higher than the other CD apps below since release cadence bursts can hit
    # several deploys within a single day)
    "admin" = {
      lifecycle_policy           = true
      production_images_to_keep  = 15
      development_images_to_keep = 30
    },
    "backend" = {
      lifecycle_policy           = true
      production_images_to_keep  = 15
      development_images_to_keep = 30
    },
    "frontend" = {
      lifecycle_policy           = true
      production_images_to_keep  = 15
      development_images_to_keep = 30
    },
    # Scheduled lambdas
    "database-backups" = {
      lifecycle_policy           = true
      production_images_to_keep  = 5
      development_images_to_keep = 5
    },
    "database-replication" = {
      lifecycle_policy           = true
      production_images_to_keep  = 5
      development_images_to_keep = 5
    },
    # Continuous deployment applications
    "fpo-search" = {
      lifecycle_policy           = true
      production_images_to_keep  = 10
      development_images_to_keep = 30
    },
    "dev-hub" = {
      lifecycle_policy           = true
      production_images_to_keep  = 10
      development_images_to_keep = 30
    }
    "identity" = {
      lifecycle_policy           = true
      production_images_to_keep  = 10
      development_images_to_keep = 30
    },
    "ai-search-evaluation-suite" = {
      lifecycle_policy           = true
      production_images_to_keep  = 10
      development_images_to_keep = 30
    },
    "mcp" = {
      lifecycle_policy           = true
      production_images_to_keep  = 10
      development_images_to_keep = 30
    },
  }
}
