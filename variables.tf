variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "aws region"
}

variable "bucket_name" {
  type        = string
  description = "name of the bucket, it must be a global."
}
