terraform {
  # ✅ Specify the required Terraform version
  required_version = ">= 1.5.0"

  # ✅ Specify provider and version
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

terraform {
  backend "s3" {
    bucket = "sctp-core-tfstate"
    key    = "marlon.tfstate" #Change this 
    region = "ap-southeast-1"
  }
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = lower(split("/", "${data.aws_caller_identity.current.arn}")[1])
  account_id  = data.aws_caller_identity.current.account_id
}

/*
resource "aws_s3_bucket" "s3-tf" {
  bucket = lower("${local.name_prefix}-s3-tf-bkt-${local.account_id}")
}
*/

# ✅ Updated S3 bucket resource without deprecated interpolation
resource "aws_s3_bucket" "my_bucket" {
  bucket = lower(format("%s-s3-tf-bkt-%s", var.name_prefix, random_id.bucket_id.hex))
  # bucket = lower(var.name_prefix + "-s3-tf-bkt-" + tostring(random_id.bucket_id.dec))
  acl    = "private"
}

# Example variable for name_prefix
variable "name_prefix" {
  type        = string
  description = "Prefix for S3 bucket names"
  default     = "marlonp"
}
