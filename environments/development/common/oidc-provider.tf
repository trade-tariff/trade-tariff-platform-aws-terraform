resource "aws_iam_openid_connect_provider" "circleci_oidc" {

  url             = "https://oidc.circleci.com/org/${var.circleci_organisation_id}"
  client_id_list  = [var.circleci_organisation_id]
  thumbprint_list = var.thumbprint_list
}

resource "aws_iam_openid_connect_provider" "github_oidc" {

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}
