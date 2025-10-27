provider "aws" {
  region = "us-east-1"
}

terraform {
  # Specify the required Terraform version
  required_version = ">= 1.0.0"

  # Specify provider and version
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "sctp-ce11-tfstate"
    key    = "marlon32.tfstate" #Change this 
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = split("/", data.aws_caller_identity.current.arn)[1]  
  # lower(split("/", "${data.aws_caller_identity.current.arn}")[1])
  account_id  = data.aws_caller_identity.current.account_id
}

# Updated S3 bucket resource without deprecated interpolation
resource "aws_s3_bucket" "s3_tf" {
  # checkov:skip=CKV_AWS_145:Ensure that S3 buckets are encrypted with KMS by default
  # checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  # checkov:skip=CKV2_AWS_62:Ensure S3 buckets should have event notifications enabled
  # checkov:skip=CKV2_AWS_6:Ensure that S3 bucket has a Public Access block
  # checkov:skip=CKV2_AWS_61:Ensure that an S3 bucket has a lifecycle configuration
  # checkov:skip=CKV_AWS_21:Ensure all data stored in the S3 bucket have versioning enabled
  # checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled
  bucket = format("%s-s3-tf-bkt-%s", local.name_prefix, tostring(local.account_id))  # bucket = "${local.name_prefix}-s3-tf-bkt-${local.account_id}"
}