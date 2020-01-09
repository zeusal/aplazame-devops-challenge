//AWS Account
variable "aws_access_key" {
  type    = string
  default = ""
 }
variable "aws_secret_key" {
  type    = string
  default = ""
 }
variable "aws_region"     { 
  type    = string
  default = "eu-west-1"
}

// Project Vars
variable "project"          { }
variable "environment"      { }
variable "ec2_image" {
  type    = string
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
variable "size_cluster"     { }
variable "asg_max_size"     { }
variable "asg_min_size"     { }
variable "asg_desired_size" { }
variable "ecs_replica"      { }