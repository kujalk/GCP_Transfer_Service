provider "google" {
  credentials = var.keyfile
  project     = var.project-id
}

provider "aws" {
  region     = "ap-southeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}