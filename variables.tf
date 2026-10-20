variable "region" {
  default = "me-central-1"
}

variable "my_ip" {
  description = "your public ip for ssh, example: 1.2.3.4/32"
  type        = string
}

variable "key_name" {
  description = "name of an existing EC2 key pair (optional)"
  type        = string
  default     = null
}

output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "bucket_name" {
  value = aws_s3_bucket.site.id
}
