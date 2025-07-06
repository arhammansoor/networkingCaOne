# This file is declaring variables that are used in the main.tf file

variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "The AMI ID "
  type        = string
  default     = "ami-0fab1b527ffa9b942" # Amazon Linux 2023 AMI in eu-west-1
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the EC2 key pair"
  type        = string
  default     = "app-key-pair"
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
  default     = "~/.ssh/aws_key.pub"
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
  default     = "~/.ssh/aws_key"
}
