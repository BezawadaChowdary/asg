// non-elb asg or alb attached
resource "aws_autoscaling_group" "asg-ng" {
  count = "${var.enable_elb != "true" ? 1 : 0 }"

  lifecycle {
    create_before_destroy = true
  }

  # We generate a name that inscludes the launch config name to force a recreate
  name = "asg-${var.name}-${var.root_volume_type != "io1" ? aws_launch_configuration.lc.name : aws_launch_configuration.lc-io1.name}"

  vpc_zone_identifier = ["${split(",", var.vpc_zone_subnets)}"]

  # Uses the ID from the launch config created above
  launch_configuration = "${var.root_volume_type != "io1" ? aws_launch_configuration.lc.id : aws_launch_configuration.lc-io1.id}"
  
  target_group_arns = [
    "${concat(
      "${aws_alb_target_group.autoscaling_alb_target_group.*.arn}",
      flatten(var.target_groups))}",
  ]

  min_size         = "${var.asg_min_instances}"
  max_size         = "${var.asg_max_instances}"
  desired_capacity = "${var.asg_instances}"

  wait_for_elb_capacity     = "${var.asg_min_instances}"
  wait_for_capacity_timeout = "${var.asg_wait_for_capacity_timeout}"

  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${coalesce (var.health_check_type, (var.enable_elb == "true" ? "ELB" : "EC2"))}"

  #load_balancers = ["${split(",", var.load_balancer_names)}"]
  tags = ["${concat(var.tags, list(map("key", "Name", "value", "asg-${var.name}-${var.root_volume_type != "io1" ? aws_launch_configuration.lc.name : aws_launch_configuration.lc-io1.name}", "propagate_at_launch", "true")),
                            list(map("key", "Environment", "value", "${var.environment}", "propagate_at_launch", "true")),
                            list(map("key", "Team", "value", "${var.team}", "propagate_at_launch", "true")),
                            list(map("key", "Role", "value", "${var.role}", "propagate_at_launch", "true")),
                            list(map("key", "Service", "value", "${var.service}", "propagate_at_launch", "true")),
                            list(map("key", "Owner", "value", "${var.owner}", "propagate_at_launch", "true")),
                            list(map("key", "Description", "value", "${var.description}", "propagate_at_launch", "true")),
                            list(map("key", "Product", "value", "${var.product}", "propagate_at_launch", "true")),
                            list(map("key", "OffHours", "value", "${var.offhours}", "propagate_at_launch", "true")))}"]
}
