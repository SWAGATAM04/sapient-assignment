resource "aws_iam_user" "web_restart_user" {
  name = var.user_name
}

resource "aws_iam_user_policy" "web_restart_policy" {
  name = "RestartWebInstancesPolicy"
  user = aws_iam_user.web_restart_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:RebootInstances"
        ],
        Resource = "*"
      }
    ]
  })
}

