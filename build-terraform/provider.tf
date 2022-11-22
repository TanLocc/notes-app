terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
  access_key = "AKIAWFSFABL3M3B75ZLQ"
  secret_key = "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"
}
