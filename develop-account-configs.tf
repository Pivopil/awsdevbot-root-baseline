variable "develop_assume_role" {
}

provider "aws" {
  alias = "develop"
  assume_role {
    role_arn = var.develop_assume_role
  }
}

resource "aws_s3_bucket" "develop-s3" {
  provider      = aws.develop
  bucket_prefix = "develop-s3-bucket-"
}



