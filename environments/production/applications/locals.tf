locals {
  account_id = data.aws_caller_identity.current.account_id
  applications = [
    "admin",
    "backend",
    "database-backups",
    "dev-hub",
    "duty-calculator",
    "fpo-search",
    "frontend",
    "tea"
  ]
}
