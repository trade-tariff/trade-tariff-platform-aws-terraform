locals {
  account_id = data.aws_caller_identity.current.account_id
  applications = [
    "admin",
    "backend",
    "duty-calculator",
    "dev-hub",
    "frontend",
    "tea"
  ]
}
