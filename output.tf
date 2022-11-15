# output "aws_lb_url" {
#   description = ""
#   value       = aws_lb.tf_alb.dns_name
# }


# output "eip" {
#   description = "EIP for VIP"
#   value       = aws_eip.VIP_eip.public_ip
# }


output "MASTER-ID" {
  description = "MASTER-ID"
  value       = aws_instance.LB1.id
}



output "BACKUP-ID" {
  description = "BACKUP-ID"
  value       = aws_instance.LB2.id
}