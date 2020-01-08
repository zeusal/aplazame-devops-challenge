//AWS Account
aws_access_key            = ""
aws_secret_key            = ""
aws_region                = "eu-west-1" #Ireland

// Project Vars
project                   = "Aplazame"
environment               = "dev"
resource_prefix           = "aplazame"
ec2_key                   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnbPdwZKYhSV6kJ1RGcv6NHYJwAbSELe2z6CzwyMfryp57fMAgHT2ycr9XmhNBejISVyDv/PJX7ZPJmfel3+V0UqN+exdUc8YOGMg2bhucxmUpliyZiY+ryuxlleKALfLQy7OcqNt/P/lWgYoql7UrDl6uE7Mw+cM87ukrRbSwItr4uO393w+Qen+8b6MCUEh8JhOhuB1SfmUosfpEp4fkisAEZsuKY1ytCet9KXRRJM42oNfkC1ecP3GcoVm6kWmMDfQYMrv9WTNk7UBIT8tpcGm1jCjCCDejn8uhAlWu4xGibtVuyha5tLMHG7Mlwh4NvHJYFYk43zrkRCs1BXdL root@CPX-D3WY78WCUZ4"

// AWS Netwok
vpc_cidr                  = "11.0.0.0/16"
subnet_pub_cidr           = ["11.0.0.0/24", "11.0.1.0/24", "11.0.2.0/24"]
subnet_int_cidr           = ["11.0.3.0/24", "11.0.4.0/24", "11.0.5.0/24"]

// Compute vars
size_cluster                  = {
  dev     = "t2.micro"
  qa      = "t2.micro"
  staging = "t2.micro"
  prod    = "t2.micro"
}
