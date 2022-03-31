# resource "aws_iam_role" "tf-codepipeline-role" {
#   name = "tf-codepipeline-role"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "codepipeline.amazonaws.com"
#         }
#       },
#     ]
#   })

# }

# data "aws_iam_policy_document" "tf-cicd-pipeline-policies" {
#   statement {
#     sid = ""
#     actions = [ "codestar-connections:UserConnection" ]
#     resources = [ "*" ]
#     effect = "Allow"
#   }
#   statement {
#     sid = ""
#     actions = [ "cloudwatch:*", "s3:*", "codebuild:*" ]
#     resources = [ "*" ]
#     effect = "Allow"
#   }
# }

# resource "aws_iam_policy" "tf-cicd-pipeline-policy" {
#   name = "tf-cicd-pipeline-policy"
#   path = "/"
#   description = "Policy for CodePipeline"
#   policy = data.aws_iam_policy_document.tf-cicd-pipeline-policies.json
# }

# resource "aws_iam_policy_attachment" "tf-cicd-pipeline-attachment" {
#     name = "tf-cicd-pipeline-attachment"
#     roles = [
#     aws_iam_role.tf-codepipeline-role.id,
#   ]
#   policy_arn = aws_iam_policy.tf-cicd-pipeline-policy.arn
# }
  
# resource "aws_iam_role" "tf-codebuild-role" {
#   name = "tf-codebuild-role"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "codebuild.amazonaws.com"
#         }
#       },
#     ]
#   })

# }

# data "aws_iam_policy_document" "tf-cicd-build-policies" {
#   statement {
#     sid = ""
#     actions = [ "logs:*", "s3:*", "codebuild:*", "secretsmanager:*", "iam:*" ]
#     resources = [ "*" ]
#     effect = "Allow"
#   }
# }

# resource "aws_iam_policy" "tf-cicd-build-policy" {
#   name = "tf-cicd-build-policy"
#   path = "/"
#   description = "Policy for Codebuild"
#   policy = data.aws_iam_policy_document.tf-cicd-build-policies.json
# }

# resource "aws_iam_policy_attachment" "tf-cicd-build-attachment-1" {
#     name = "tf-cicd-build-attachment-1"
#     roles = [
#     aws_iam_role.tf-codebuild-role.id,
#   ]
#   policy_arn = aws_iam_policy.tf-cicd-build-policy.arn
# }

# resource "aws_iam_policy_attachment" "tf-cicd-build-attachment-2" {
#     name = "tf-cicd-build-attachment-2"
#     roles = [
#     aws_iam_role.tf-codebuild-role.id,
#   ]
#   policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
# }

resource "aws_iam_role" "tf-codepipeline-role" {
  name = "tf-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "tf-cicd-pipeline-policies" {
    statement{
        sid = ""
        actions = ["codestar-connections:UseConnection"]
        resources = ["*"]
        effect = "Allow"
    }
    statement{
        sid = ""
        actions = ["cloudwatch:*", "s3:*", "codebuild:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "tf-cicd-pipeline-policy" {
    name = "tf-cicd-pipeline-policy"
    path = "/"
    description = "Pipeline policy"
    policy = data.aws_iam_policy_document.tf-cicd-pipeline-policies.json
}

resource "aws_iam_role_policy_attachment" "tf-cicd-pipeline-attachment" {
    policy_arn = aws_iam_policy.tf-cicd-pipeline-policy.arn
    role = aws_iam_role.tf-codepipeline-role.id
}


resource "aws_iam_role" "tf-codebuild-role" {
  name = "tf-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "tf-cicd-build-policies" {
    statement{
        sid = ""
        actions = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*","iam:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "tf-cicd-build-policy" {
    name = "tf-cicd-build-policy"
    path = "/"
    description = "Codebuild policy"
    policy = data.aws_iam_policy_document.tf-cicd-build-policies.json
}

resource "aws_iam_role_policy_attachment" "tf-cicd-codebuild-attachment-1" {
    policy_arn  = aws_iam_policy.tf-cicd-build-policy.arn
    role        = aws_iam_role.tf-codebuild-role.id
}

resource "aws_iam_role_policy_attachment" "tf-cicd-codebuild-attachment-2" {
    policy_arn  = "arn:aws:iam::aws:policy/PowerUserAccess"
    role        = aws_iam_role.tf-codebuild-role.id
}