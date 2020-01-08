//AWS Account
variable "aws_access_key" { }
variable "aws_secret_key" { }
variable "aws_region"     { }

// Project Vars
variable "project"          { }
variable "environment"      { }
variable "ec2_image" {
    type = string
    default = "ami-027078d981e5d4010"
}
variable "ec2_key"          { }
variable "resource_prefix"  { }


// AWS Netwok
variable "vpc_cidr"         { }

variable "subnet_pub_cidr" {
  type = list
}

variable "subnet_int_cidr" {
  type = list
}

// Compute vars
variable "size_cluster" {
  type = map
}