/*
  SG from all to 40 and 443 
*/
resource "aws_security_group" "alb_external" {
  name        = "alb-ext-${var.project}-${terraform.workspace}"
  description = "Allow 80 and 443 port inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "alb-ext-${var.project}-${terraform.workspace}",
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
}

/*
  SG from self SG to all port
*/
resource "aws_security_group" "allow_internal" {
  name        = "all-int-${var.project}-${terraform.workspace}"
  description = "Allow all port inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol  = "-1"
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "all-int-${var.project}-${terraform.workspace}",
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
}