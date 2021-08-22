# all other ressources can be generated in europa zone
provider "aws" {
  region  = "eu-central-1"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-state-lars-willrich"
    key            = "larswillrich/analyse-stock-market/terraform.tfstate"
    region         = "eu-central-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

resource "aws_iam_role" "sagemaker" {
  name = "sagemaker"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "sagemaker.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "policy-attachment" {
  name       = "policy-attachment"
  roles      = [aws_iam_role.sagemaker.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_sagemaker_code_repository" "example" {
  code_repository_name = "my-stock-analyse"

  git_config {
    repository_url = "https://github.com/larswillrich/analyse-stock-market.git"
  }
}

resource "aws_sagemaker_notebook_instance" "ni" {
  name                    = "my-notebook-instance"
  role_arn                = aws_iam_role.sagemaker.arn
  instance_type           = "ml.t2.medium"
  default_code_repository = aws_sagemaker_code_repository.example.code_repository_name
}