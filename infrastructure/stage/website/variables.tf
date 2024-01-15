variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "website_domain_name" {
  type        = string
  default     = "kxlaaaws.com"
  description = "The domain name of the static site without the www prefix"
}

