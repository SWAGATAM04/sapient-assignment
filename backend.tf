terraform {
  backend "s3" {
    bucket         = "zantac-terraform-state-latest"
    key            = "env/dev/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "zantac-tf-locks"
    encrypt        = true
  }
}

