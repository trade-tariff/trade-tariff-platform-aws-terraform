locals {
  # We have a mixture of release-prefixed tagged images and untagged images.
  #
  # Untagged images are considered "development" images but this is not always the
  # case since some applications don't cut a release tag to identify a
  # deployment as released to production (e.g. for different classes of lambda or applications owned
  # by a different upstream).
  #
  # The main case, though, is that we keep 5 production images and 30
  # development images (with the production image prioritised higher and
  # therefore taking precedence).
  #
  # Production releases happen 2 times per week (until we move to continuous
  # deployment) so 5 production images is equivalent to keeping the last 2.5 weeks of images.
  #
  # We have a higher number of development images to reflect the fact that there
  # can be a lot of concurrently built images across different branches and
  # developers aren't always incentivised to clean up after themselves and have
  # long-lived branches.
  #
  # In the case of continous deployment, we would likely want to keep more just
  # to be safe (e.g. the hub-backend and hub-frontend applications and fpo
  # search lambda).
  #
  # The lifecycle policy is just a convenience to disable application lifecycles
  # in an emergency.
  applications = {
    # Manually deployed typical applications
    "admin" = {
      lifecycle_policy           = true
      production_images_to_keep  = 5
      development_images_to_keep = 30
    },
    "backend" = {
      lifecycle_policy           = true
      production_images_to_keep  = 5
      development_images_to_keep = 30
    },
    "frontend" = {
      lifecycle_policy           = true
      production_images_to_keep  = 5
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
    "examples" = {
      lifecycle_policy           = true
      production_images_to_keep  = 10
      development_images_to_keep = 30
    }
    "identity" = {
      lifecycle_policy           = true
      production_images_to_keep  = 10
      development_images_to_keep = 30
    },
    "tea" = {
      lifecycle_policy           = true
      production_images_to_keep  = 10
      development_images_to_keep = 30
    },
    "terraform" = {
      lifecycle_policy           = true
      production_images_to_keep  = 5
      development_images_to_keep = 5
    },
  }
}
