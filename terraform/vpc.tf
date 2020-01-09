# Declare the data source
data "aws_availability_zones" "available" {}

resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "default"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags = {
    Name        = "aws-${var.resource_prefix}-${terraform.workspace}",
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id     = "${aws_vpc.default.id}"
  depends_on = [aws_vpc.default]
  tags = {
    Name        = "gw-${var.resource_prefix}-${terraform.workspace}",
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
}

/*
  Public Subnet
*/
resource "aws_subnet" "eu-west-1a-public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${var.subnet_pub_cidr[0]}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  depends_on        = [aws_vpc.default]
  tags = {
    Name        = "Subnet1a-${var.resource_prefix}-${terraform.workspace}",
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "eu-west-1b-public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${var.subnet_pub_cidr[1]}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  depends_on        = [aws_vpc.default]
  tags = {
    Name        = "Subnet1b-${var.resource_prefix}-${terraform.workspace}",
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "eu-west-1c-public" {
  vpc_id            = "${aws_vpc.default.id}"
  depends_on        = [aws_vpc.default]
  cidr_block        = "${var.subnet_pub_cidr[2]}"
  availability_zone = "${data.aws_availability_zones.available.names[2]}"

  tags = {
    Name        = "Subnet1c-${var.resource_prefix}-${terraform.workspace}",
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = "${aws_vpc.default.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"

}
