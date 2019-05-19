// target_id generates a random 28-character ID for use as the unique ID for
// our target group. The byte length is actually 14 bytes so that it can be
// rendered as hex.
resource "random_id" "nlb_target_id" {
  count       = "${var.enable_nlb == "true" ? 1 : 0 }"
  byte_length = 14
}

// autoscaling_nlb_target_group creates the ALB target group.
resource "aws_lb_target_group" "autoscaling_nlb_target_group" {
  count    = "${var.enable_nlb == "true" ? 1 : 0 }"
  name     = "TG-${random_id.nlb_target_id.hex}"
  port     = "${var.nlb_service_port}"
  protocol = "${var.nlb_target_protocol}"
  vpc_id   = "${data.aws_subnet.primary_subnet.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "${var.nlb_target_protocol}"
    interval            = "${var.nlb_health_check_interval}"
    port                = "${var.nlb_health_check_port}"
  }
}
