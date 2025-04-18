variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "index_document" {
  description = "The index document for the website"
  type        = string
}

variable "frontend_directory" {
  description = "The directory containing frontend files"
  type        = string
}

variable "zone_id" {
  description = "The directory containing frontend files"
  type        = string
}

variable "domain_name" {
  type = string
}

variable "error_document" {
  description = "The error document for the website"
  type        = string
}

variable "region" {
  description = "The region resource will be provisioned in"
  type        = string
}

variable "frontend_path" {
  description = "Path to frontend config.json"
  type        = string
}

