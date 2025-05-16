data "aws_iam_policy_document" "breakglass_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::036807458659:user/trade-tariff-breakglass"]
    }
  }
}

resource "aws_iam_role" "breakglass" {
  name               = "breakglass-role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.breakglass_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "breakglass_role_policy_attachment" {
  role       = aws_iam_role.breakglass.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
