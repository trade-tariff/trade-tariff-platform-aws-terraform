locals {
  account_id = data.aws_caller_identity.current.account_id
  applications = [
    "admin",
    "backend",
    "dev-hub",
    "frontend",
    "identity",
    "tea"
  ]
}
