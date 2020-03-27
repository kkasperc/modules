
data "aws_availability_zones" "all" {}
data "aws_vpc" "selected" {}


resource aws_alb "apploadbalancer"{
  name = "${var.cluster_name}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.sec_gr_http.id]
  #vpc_id = "vpc-0d935167"
  subnets = ["subnet-58b01a32","subnet-3f618043", "subnet-821ce8ce"]
}

resource "aws_alb_target_group" "alb-target-group" {
  name     = "${var.cluster_name}-alb-target-group"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.selected.id
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.grupa_startowa.id
  alb_target_group_arn   = aws_alb_target_group.alb-target-group.arn
}

# Define a listener
resource "aws_alb_listener" "alb-listner" {
  load_balancer_arn = aws_alb.apploadbalancer.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2015-05"
  #certificate_arn   = "${var.ssl_arn}"

  default_action {
    target_group_arn = aws_alb_target_group.alb-target-group.arn
    type             = "forward"
  }
}


resource "aws_lb_listener_rule" "listnerrule" {
  listener_arn = aws_alb_listener.alb-listner.arn
  priority     = 99

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.alb-target-group.arn
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}

resource aws_launch_configuration "vmki"{
  name = "${var.cluster_name}-vmki"
  image_id = "ami-05af9eea1ba999713"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.sec_gr_http.id]

  user_data = <<-EOF
              #!/bin/bash
              yum install httpd -y
              echo "Hello, World" > /var/www/html/index.html
              systemctl start httpd
              EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource aws_autoscaling_group "grupa_startowa"{
  launch_configuration = aws_launch_configuration.vmki.id
  availability_zones   = data.aws_availability_zones.all.names
  #target_group_arns
  min_size = var.min_size
  max_size = var.max_size

tag {
  key = "Name"
  value = "${var.cluster_name}-Auto Size Group"
  propagate_at_launch = true
}
}

# resource "aws_instance" "probny" {
# 	ami = "ami-05af9eea1ba999713"
# 	instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.sec_gr_http.id]

# user_data = <<-eof
#               #!/bin/bash
#               yum install httpd -y
#               echo "hello, world" > /var/www/html/index.html
#               systemctl start httpd
#               eof
#   tags = {
#     name = "terraform-example"
#   }
# }

resource "aws_security_group" "sec_gr_http" {
  name = "${var.cluster_name}-Allow http"
  description = "Allow traffic on port 80"

  ingress{
    description = "Allow port 80"
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "Allow port 80"
  }

  egress {
    description = "Allow all outboud"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# output "IP" {
#   value = "curl http://${aws_instance.Probny.public_ip}:${var.server_port}"
# }
# output "hostname" {
#   value = "${aws_instance.Probny.public_dns}"
# }


