resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key-${var.resource_prefix}-${var.environment}"
  public_key = "${var.ec2_key}"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project}-${var.environment}"

  tags = {
    Name        = "${var.resource_prefix}-${var.environment}"
    Project     = "${var.project}",
    Environment = "${var.environment}"
  }
}

resource "aws_launch_configuration" "ecs_launch_configuration" {
  name                 = "lc-${var.resource_prefix}-${var.environment}"
  image_id             = "${var.ec2_image}"
  instance_type        = "${var.size_cluster["dev"]}"
  iam_instance_profile = "arn:aws:iam::640057356796:instance-profile/ecsInstanceRole"

  root_block_device {
    volume_type           = "standard"
    volume_size           = 30
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = ["${aws_security_group.allow_internal.id}"]
  associate_public_ip_address = "true"
  key_name                    = "${aws_key_pair.deployer.key_name}"
  user_data                   = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.project}-${var.environment} >> /etc/ecs/ecs.config
  EOF
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                 = "asg-${var.resource_prefix}-${var.environment}"
  max_size             = "1"
  min_size             = "0"
  desired_capacity     = "1"
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1a-public.id}", "${aws_subnet.eu-west-1b-public.id}", "${aws_subnet.eu-west-1c-public.id}"]
  launch_configuration = "${aws_launch_configuration.ecs_launch_configuration.name}"
  health_check_type    = "EC2"
  depends_on           = [aws_launch_configuration.ecs_launch_configuration]
}

data "aws_ecs_task_definition" "nginx_check_task" {
  task_definition = "${aws_ecs_task_definition.nginx.family}"
  depends_on      = [aws_ecs_task_definition.nginx]
}

resource "aws_ecs_task_definition" "nginx" {
  family                = "nginx"
  memory                = "512"
  cpu                   = "1024"
  network_mode          = "bridge"
  container_definitions = "${file("task-definitions/service.json")}"
  depends_on            = [aws_ecs_cluster.ecs_cluster]

  tags = {
    Project     = "${var.project}",
    Environment = "${var.environment}"
  }
}


resource "aws_alb" "ecs-load-balancer" {
  name            = "ecs-lb-${var.resource_prefix}-${var.environment}"
  security_groups = ["${aws_security_group.alb_external.id}", "${aws_security_group.allow_internal.id}"]
  subnets         = ["${aws_subnet.eu-west-1a-public.id}", "${aws_subnet.eu-west-1b-public.id}", "${aws_subnet.eu-west-1c-public.id}"]
  tags = {
    Name        = "ecs-lb-${var.resource_prefix}-${var.environment}",
    Project     = "${var.project}",
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "ecs-target-group" {
  name       = "ecs-tg-${var.resource_prefix}-${var.environment}"
  port       = "80"
  protocol   = "HTTP"
  vpc_id     = "${aws_vpc.default.id}"
  depends_on = [aws_alb.ecs-load-balancer]
  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags = {
    Name        = "ecs-tg-${var.resource_prefix}-${var.environment}",
    Project     = "${var.project}",
    Environment = "${var.environment}"
  }
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = "${aws_alb.ecs-load-balancer.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb.ecs-load-balancer]
  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
    type             = "forward"
  }
}

resource "aws_ecs_service" "nginx-ecs-service" {
  name            = "nginx-ecs-srv-${var.resource_prefix}-${var.environment}"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.nginx.family}:${max("${aws_ecs_task_definition.nginx.revision}", "${data.aws_ecs_task_definition.nginx_check_task.revision}")}"
  desired_count   = 3
  launch_type     = "EC2"
  depends_on      = [aws_ecs_task_definition.nginx]
  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
    container_port   = 80
    container_name   = "nginx_aplazame"
  }
}