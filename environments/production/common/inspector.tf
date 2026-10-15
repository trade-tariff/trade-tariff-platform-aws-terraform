resource "aws_inspector2_enabler" "this" {
  account_ids    = [local.account_id]
  resource_types = ["ECR", "LAMBDA"]
}

resource "aws_inspector2_filter" "suppress_no_fix_available" {
  name        = "Suppress Inspector Findings with No Fix Available"
  description = "Suppress Amazon Inspector ECR vulnerability findings where no fixed version is currently available."
  action      = "SUPPRESS"

  filter_criteria {
    resource_type {
      comparison = "EQUALS"
      value      = "AWS_ECR_CONTAINER_IMAGE"
    }

    fix_available {
      comparison = "EQUALS"
      value      = "NO"
    }
  }

  depends_on = [aws_inspector2_enabler.this]
}
