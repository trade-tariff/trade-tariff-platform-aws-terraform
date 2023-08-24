locals {
  account_id = data.aws_caller_identity.current.account_id
  applications = [
    "admin",
    "backend",
    "duty-calculator",
    "frontend",
    "search-query-parser",
    "signon"
  ]
}
