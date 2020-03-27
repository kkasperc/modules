output "alb_dns_name" {
  value       = aws_alb.apploadbalancer.dns_name
  description = "The domain name of the load balancer"
}