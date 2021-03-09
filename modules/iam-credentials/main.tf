data "aws_iam_policy_document" "baseline_iam_policy_document" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.target_account_id}:role/OrganizationAccountAccessRole"]

  }
}

resource "aws_iam_user" "baseline" {
  name = "${var.env}-baseline"
}

resource "aws_iam_access_key" "baseline_iam_access_key" {
  user = aws_iam_user.baseline.name
}

resource "aws_iam_user_policy" "baseline_iam_user_policy" {
  name   = "${var.env}-baseline-user-policy"
  policy = data.aws_iam_policy_document.baseline_iam_policy_document.json
  user   = aws_iam_user.baseline.name
}

resource "aws_secretsmanager_secret" "iam_user_keys" {
  name                    = "${var.env}-baseline-iam-keys"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "iam_user_keys_version" {
  secret_id = aws_secretsmanager_secret.iam_user_keys.id
  secret_string = jsonencode({
    id               = aws_iam_access_key.baseline_iam_access_key.id
    encrypted_secret = aws_iam_access_key.baseline_iam_access_key.encrypted_secret
    secret           = aws_iam_access_key.baseline_iam_access_key.secret
  })
}
