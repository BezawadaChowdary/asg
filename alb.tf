// target_id generates a random 28-character ID for use as the unique ID for
// our target group. The byte length is actually 14 bytes so that it can be
// rendered as hex.
resource "random_id" "target_id" {
  count       = "${var.enable_alb == "true" ? 1 : 0 }"
  byte_length = 14
}

// autoscaling_alb_target_group creates the ALB target group.
resource "aws_alb_target_group" "autoscaling_alb_target_group" {
  count    = "${var.enable_alb == "true" ? 1 : 0 }"
  name     = "TG-${random_id.target_id.hex}"
  port     = "${var.alb_service_port}"
  protocol = "${var.alb_target_protocol}"
  vpc_id   = "${data.aws_subnet.primary_subnet.vpc_id}"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${lookup(map("", "1"), var.alb_stickiness_duration, var.alb_stickiness_duration)}"
    enabled         = "${var.enable_stickiness}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = "${var.alb_health_check_timeout}"
    path                = "${var.alb_health_check_uri}"
    protocol            = "${var.alb_target_protocol}"
    interval            = "${var.alb_health_check_interval}"
    port                = "${var.alb_health_check_port}"
  }
}

// autoscaling_alb_listener_rule creates a listener rule for the specified
// listener and the path patterns supplied.
resource "aws_alb_listener_rule" "autoscaling_alb_listener_rule" {
  count        = "${var.enable_alb == "true" ? 1 : 0 }"
  listener_arn = "${var.alb_listener_arn}"
  priority     = "${var.alb_rule_number}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.autoscaling_alb_target_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["${var.alb_path_patterns}"]
  }
}
