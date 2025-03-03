terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-bucket-easytransfer"
    key    = "frontend/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
