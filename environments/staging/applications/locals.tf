locals {
  account_id = data.aws_caller_identity.current.account_id
  applications = [
    "admin",
    "backend",
    "duty-calculator",
    "dev-hub",
    "fpo-developer-hub-backend",
    "fpo-developer-hub-frontend",
    "frontend",
    "signon",
    "tea"
  ]
}
