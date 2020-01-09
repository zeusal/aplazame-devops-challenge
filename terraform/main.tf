/*
  Save tfstate in Terraform Cloud
*/
terraform {
  required_version = "~> 0.12"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "zeusal"
    workspaces { prefix = "aplazame-devops-challenge-" }
  }
}