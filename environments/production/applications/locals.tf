locals {
  account_id = data.aws_caller_identity.current.account_id
  applications = [
    "admin",
    "backend",
    "database-backups",
    "duty-calculator",
    "fpo-search",
    "frontend",
    "search-query-parser",
    "signon",
    "terraform-1.5.5-python3",
  ]
}
