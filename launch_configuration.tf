resource "aws_launch_configuration" "lc" {
  lifecycle {
    create_before_destroy = true
  }

  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = "${var.associate_public_ip}"
  iam_instance_profile        = "${var.instance_profile}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_group}"]
  user_data                   = "${data.template_cloudinit_config.userdata.rendered}"

  ebs_optimized = "${var.ebs_optimized}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}"
  }
}

resource "aws_launch_configuration" "lc-io1" {
  lifecycle {
    create_before_destroy = true
  }

  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = "${var.associate_public_ip}"
  iam_instance_profile        = "${var.instance_profile}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_group}"]
  user_data                   = "${data.template_cloudinit_config.userdata.rendered}"

  ebs_optimized = "${var.ebs_optimized}"

  root_block_device {
    volume_type = "io1"
    volume_size = "${var.root_volume_size}"
    iops        = "${var.root_volume_iops}"
  }
}

data "template_cloudinit_config" "userdata" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${var.user_data == "" ? file("${path.module}/blank_user_data.sh") : var.user_data}"
  }
}
