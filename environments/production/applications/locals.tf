locals {
  account_id = data.aws_caller_identity.current.account_id
  applications = [
    "admin",
    "backend",
    "duty-calculator",
    "frontend",
    "search-query-parser",
    "signon",
    "terraform-1.5.5-python3"
  ]
}
