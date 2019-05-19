# Output the ID of the Launch Config
output "lc_id" {
  value = "${coalesce(join("", aws_launch_configuration.lc.*.id),"unknown")}"
}

output "lc_io1_id" {
  value = "${coalesce(join("", aws_launch_configuration.lc-io1.*.id),"unknown")}"
}

# Output the ID of the Autoscaling Group
output "asg_id" {
  value = "${coalesce(join("", aws_autoscaling_group.asg-ng.*.id), join("", aws_autoscaling_group.asg.*.id))}"
}

# Output the Name of the Autoscaling Group
output "asg_name" {
  value = "${coalesce(join("", aws_autoscaling_group.asg-ng.*.name), join("", aws_autoscaling_group.asg.*.name))}"
}

#Output the ARN of the default target group if using ALB
output "alb_target_group_arn" {
  value = "${coalesce(join("", aws_alb_target_group.autoscaling_alb_target_group.*.arn),"unknown")}"
}

output "alb_target_group_arn_suffix" {
  value = "${coalesce(join("", aws_alb_target_group.autoscaling_alb_target_group.*.arn_suffix),"unknown")}"
}
