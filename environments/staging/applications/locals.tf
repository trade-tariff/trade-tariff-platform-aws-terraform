locals {
  account_id = data.aws_caller_identity.current.account_id
  applications = [
    "admin",
    "backend",
    "duty-calculator",
    "fpo-developer-hub-backend",
    "fpo-developer-hub-frontend",
    "frontend",
    "search-query-parser",
    "signon"
  ]
}
