
terraform {
  backend "s3" {
    bucket = "kxlaa-cloud-resume-state"
    key    = "stage/website/terraform.tfstate"
    region = "eu-west-2"

    dynamodb_table = "kxlaa-cloud-resume-state-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------
locals {
  website_bucket_name     = var.website_domain_name
  www_website_bucket_name = "www.${var.website_domain_name}"
  build_dir               = "../../../dist"
  content_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "text/javascript"
    ".svg"  = "image/svg+xml"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".ico"  = "image/x-icon"
  }
}

provider "aws" {
  region = var.region
}

#------------------------------------------------------------------------------
# Main S3 Bucket
#------------------------------------------------------------------------------

resource "aws_s3_bucket" "main_s3_bucket" {
  bucket        = local.website_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "main_s3_bucket_ownership" {
  bucket = aws_s3_bucket.main_s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "main_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.main_s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "main_s3_bucket_acl" {
  bucket = aws_s3_bucket.main_s3_bucket.id
  acl    = "public-read"

  depends_on = [
    aws_s3_bucket_public_access_block.main_s3_bucket_public_access_block,
    aws_s3_bucket_ownership_controls.main_s3_bucket_ownership
  ]
}

resource "aws_s3_bucket_website_configuration" "main_s3_bucket_website" {
  bucket = aws_s3_bucket.main_s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_bucket_policy" "main_s3_bucket_bucket_policy" {
  bucket = aws_s3_bucket.main_s3_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${local.website_bucket_name}/*"
        ]
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_acl.main_s3_bucket_acl,
    aws_s3_bucket_website_configuration.main_s3_bucket_website
  ]
}

resource "aws_s3_object" "main_s3_bucket_files" {
  //copy all files and folders in the dist folder in the root of the project
  for_each     = fileset(local.build_dir, "**/*")
  bucket       = aws_s3_bucket.main_s3_bucket.id
  source       = "${local.build_dir}/${each.value}"
  key          = each.value
  source_hash  = filemd5("${local.build_dir}/${each.value}")
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
}


#------------------------------------------------------------------------------
# Redirect S3 Bucket
#------------------------------------------------------------------------------

resource "aws_s3_bucket" "redirect_s3_bucket" {
  bucket        = local.www_website_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "redirect_s3_bucket_ownership" {
  bucket = aws_s3_bucket.redirect_s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "redirect_s3_bucket_website" {
  bucket = aws_s3_bucket.redirect_s3_bucket.id

  redirect_all_requests_to {
    host_name = local.website_bucket_name
    protocol  = "http"
  }
}
