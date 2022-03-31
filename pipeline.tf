resource "aws_codebuild_project" "tf-plan" {
  name          = "tf-cicd-plan"
  description   = "Plan stage for Terraform"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-apply" {
  name          = "tf-cicd-apply"
  description   = "Apply stage for Terraform"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }
}

resource "aws_codepipeline" "cicd_pipeline" {
  name          = "tf-cicd"
  role_arole_arn = aws_iam_role.tf-codepipeline-role.arn

  artifacts_store {
    type = "s3"
    location = aws_s3_bucket.codepipeline_artifacts.id
  }

  stage {
    name = "Source"
    actions {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeStarSourceConnection"
      version = "1"
      output_artifacts = ["tf-code"]
      configuration {
        FullRepositoryId = "mramirez600/cicd_test"
        BranchName = "main"
        ConnectionArn = var.codestar_connector_credentials
        OutputArtifcatFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Plan"
    actions {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      output_artifacts = ["tf-code"]
      configuration {
        ProjectName = "tf-cicd-plan"
      }
    }
  }

  stage {
    name = "Deploy"
    actions {
      name = "Deploy"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      output_artifacts = ["tf-code"]
      configuration {
        ProjectName = "tf-cicd-apply"
      }
    }
  }
}