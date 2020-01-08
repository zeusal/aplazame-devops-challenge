resource "aws_security_group" "alb_external" {
  name        = "alb-ext-${var.project}-${var.environment}"
  description = "Allow port 80 inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["83.43.167.106/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "alb-ext-${var.project}-${var.environment}",
    Project     = "${var.project}",
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "allow_internal" {
  name        = "all-int-${var.project}-${var.environment}"
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
    Name        = "all-int-${var.project}-${var.environment}",
    Project     = "${var.project}",
    Environment = "${var.environment}"
  }
}