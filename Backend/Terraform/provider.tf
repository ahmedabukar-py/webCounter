terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
/*
provider "aws" {
  region                   = "us-west-2"
  shared_credentials_files = ["/Users/ahmedabdirahman/.aws/credentials"]
  profile                  = "vscode"
}
*/
provider "aws" {
  region                   = var.region
  shared_credentials_files = ["/Users/ahmedabdirahman/.aws/credentials"]
  profile                  = "vscode"
}