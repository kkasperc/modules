resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-ALB"
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

resource "aws_security_group" "internal-traffic" {
  name = "${var.cluster_name}-internal"
  description = "Allow traffic on port 80 Internal only"

  ingress{
    description = "Allow port 80"
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = aws_security_group.alb
  }
  tags = {
    name = "Allow port 80"
  }

  egress {
    description = "Allow all outboud"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = aws_security_group.alb
  }
}
