data "aws_iam_policy_document" "develop_baseline_iam_policy_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [var.develop_assume_role]

  }
}

resource "aws_iam_user" "develop_baseline" {
  name = "develop-baseline"
}

resource "aws_iam_access_key" "develop_baseline_iam_access_key" {
  user = aws_iam_user.develop_baseline.name
}

resource "aws_iam_user_policy" "develop_baseline_iam_user_policy" {
  name = "develop-baseline-user-policy"
  policy = data.aws_iam_policy_document.develop_baseline_iam_policy_document.json
  user = aws_iam_user.develop_baseline.name
}

resource "aws_secretsmanager_secret" "develop_iam_user_keys" {
  name = "develop-baseline-iam-keys"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "develop_iam_user_keys_version" {
  secret_id = aws_secretsmanager_secret.develop_iam_user_keys.id
  secret_string = jsonencode({
    id = aws_iam_access_key.develop_baseline_iam_access_key.id
    encrypted_secret = aws_iam_access_key.develop_baseline_iam_access_key.encrypted_secret
    secret = aws_iam_access_key.develop_baseline_iam_access_key.secret
  })
}
