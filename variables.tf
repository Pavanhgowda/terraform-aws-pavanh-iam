variable "iam_data_file" {
  description = "Path to the IAM data YAML file"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}