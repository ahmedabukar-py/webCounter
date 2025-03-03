terraform {
  backend "s3" {
    bucket         = "ahmed-webcounter-2024"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table" # Optional
  }
}
