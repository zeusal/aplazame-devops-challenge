resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key-${var.resource_prefix}-${terraform.workspace}"
  public_key = "${var.ec2_key}"
}

/*
  ASG Definition
*/
resource "aws_launch_configuration" "ecs_launch_configuration" {
  name                 = "lc-${var.resource_prefix}-${terraform.workspace}"
  image_id             = "${var.ec2_image}"
  instance_type        = "${var.size_cluster}"
  iam_instance_profile = "arn:aws:iam::640057356796:instance-profile/ecsInstanceRole"

  root_block_device {
    volume_type           = "standard"
    volume_size           = "${var.volume_size}"
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
    echo ECS_CLUSTER=ecs-${var.project}-${terraform.workspace} >> /etc/ecs/ecs.config
  EOF
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                 = "asg-${var.resource_prefix}-${terraform.workspace}"
  max_size             = "${var.asg_max_size}"
  min_size             = "${var.asg_min_size}"
  desired_capacity     = "${var.asg_desired_size}"
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1a-public.id}", "${aws_subnet.eu-west-1b-public.id}", "${aws_subnet.eu-west-1c-public.id}"]
  launch_configuration = "${aws_launch_configuration.ecs_launch_configuration.name}"
  health_check_type    = "EC2"
  depends_on           = [aws_launch_configuration.ecs_launch_configuration]

  tags = [{
    "key"               = "Name" 
    "value"             = "asg-${var.resource_prefix}-${terraform.workspace}"
    propagate_at_launch = true

    
  },{
    "key"               = "Project" 
    "value"             = "${var.project}"
    propagate_at_launch = true

  },{
    "key"               = "Environment" 
    "value"             = "${terraform.workspace}"
    propagate_at_launch = true

  }]
}


/*
  ECS Definition
*/
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-${var.project}-${terraform.workspace}"

  tags = {
    Name        = "${var.resource_prefix}-${terraform.workspace}"
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
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
    Name        = "nginx-task-${var.resource_prefix}-${terraform.workspace}"
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
}


resource "aws_ecs_service" "nginx-ecs-service" {
  name            = "nginx-ecs-srv-${var.resource_prefix}-${terraform.workspace}"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.nginx.family}:${max("${aws_ecs_task_definition.nginx.revision}", "${data.aws_ecs_task_definition.nginx_check_task.revision}")}"
  desired_count   = "${var.ecs_replica}"
  launch_type     = "EC2"
  depends_on      = [aws_ecs_task_definition.nginx]
  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
    container_port   = 80
    container_name   = "nginx_aplazame"
  }
}

/*
  ALB Definition
*/
resource "aws_alb" "ecs-load-balancer" {
  name            = "ecs-lb-${var.resource_prefix}-${terraform.workspace}"
  security_groups = ["${aws_security_group.alb_external.id}", "${aws_security_group.allow_internal.id}"]
  subnets         = ["${aws_subnet.eu-west-1a-public.id}", "${aws_subnet.eu-west-1b-public.id}", "${aws_subnet.eu-west-1c-public.id}"]
  tags = {
    Name        = "ecs-lb-${var.resource_prefix}-${terraform.workspace}",
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
}

resource "aws_alb_target_group" "ecs-target-group" {
  name       = "ecs-tg-${var.resource_prefix}-${terraform.workspace}"
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
    Name        = "ecs-tg-${var.resource_prefix}-${terraform.workspace}",
    Project     = "${var.project}",
    Environment = "${terraform.workspace}"
  }
}

resource "aws_lb_listener" "alb-http-listener" {
  load_balancer_arn = "${aws_alb.ecs-load-balancer.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb.ecs-load-balancer]
  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "alb-https-listener" {
  load_balancer_arn = "${aws_alb.ecs-load-balancer.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-west-1:640057356796:certificate/d90f0281-d845-435a-bec8-a040d4cd2349"
  depends_on        = [aws_alb.ecs-load-balancer]
  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
    type             = "forward"
  }
}
