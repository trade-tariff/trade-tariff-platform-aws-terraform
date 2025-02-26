include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  extra_arguments "init_args" {
    commands = [
      "init"
    ]

    arguments = [
      "-upgrade",
    ]
  }
}
