output "security_group_id" {
  description = "ID of the security group"
  value       = module.fcknat_sg.security_group_id
}

output "network_interface_ids" {
  description = "Map of network interface IDs"
  value = {
    for k, v in aws_network_interface.main : k => v.id
  }
}

output "instance_ids" {
  description = "Map of instance IDs"
  value = {
    for k, v in aws_instance.main : k => v.id
  }
}

# output "asg_name" {
#   description = "Name of the autoscaling group"
#   value       = var.ha_mode ? aws_autoscaling_group.main[0].name : null
# }

# output "asg_arn" {
#   description = "ARN of the autoscaling group"
#   value       = var.ha_mode ? aws_autoscaling_group.main[0].arn : null
# }
