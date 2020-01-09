//AWS Account
variable "aws_access_key" {
  type    = string
 }
variable "aws_secret_key" {
  type    = string
 }
variable "aws_region"     { 
  type    = string
  default = "eu-west-1"
}

// Project Vars
variable "project"          {
  type    = string
  default = "Aplazame"
 }
variable "environment"      {
  type    = string
  default = ""
 }
variable "resource_prefix"  {
  type    = string
  default = "aplazame"
 }

// AWS Netwok
variable "vpc_cidr"             { }
variable "subnet_pub_cidr"      {
  type = list
}
variable "subnet_int_cidr"      {
  type = list
}
variable "enable_dns_hostnames" {
  type    = bool
  default = "true"
}
variable "enable_dns_support"   {
  type    = bool
  default = "true"
}

// EC2 and ECS vars
variable "ec2_image"                   {
  type    = string
  default = "ami-027078d981e5d4010"
}
variable "ec2_key"                     { }
variable "size_cluster"                { }
variable "asg_max_size"                { }
variable "asg_min_size"                { }
variable "asg_desired_size"            { }
variable "ecs_replica"                 { }
variable "volume_size"                 {
  type    = string
  default = "30"
}
variable "associate_public_ip_address" {
  type    = bool
  default = "true"
}