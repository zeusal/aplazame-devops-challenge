output "lb_public_ip" {  
  value = "${aws_alb.ecs-load-balancer.dns_name}"
}