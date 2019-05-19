variable "name" {}

variable "ami" {
  description = "The AMI to use with the launch configuration"
  default     = "updateme"
}

variable "associate_public_ip" {
  default = false
}

variable "instance_type" {
  default = "t2.medium"
}

variable "instance_profile" {
  description = "The IAM role the launched instance will use"
  default     = ""
}

variable "key_name" {
  description = "The SSH public key name (in EC2 key-pairs) to be injected into instances"
  default     = ""
}

variable "security_group" {
  type        = "list"
  description = "ID of SG the launched instance will use"
}

variable "user_data" {
  description = "Rendered template file"
  default     = ""
  type        = "string"
}

variable "ebs_optimized" {
  description = "If the EBS volumes should be optimized or not"
  default     = "true"
  type        = "string"
}

variable "asg_instances" {
  description = "The number of instances we want in the ASG"
  default     = 2
}

variable "asg_min_instances" {
  description = "The minimum number of instances the ASG should maintain"
  default     = 2
}

variable "asg_max_instances" {
  description = "The maximum number of instances the ASG should maintain"
  default     = 4
}

variable "asg_wait_for_capacity" {
  description = "The maximum number of instances the ASG should maintain"
  default     = 4
}

variable "asg_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. Default 10m"
  default     = "10m"
}

variable "health_check_grace_period" {
  description = "Number of seconds for a health check to time out"
  default     = 300
}

/*
 * Types available are:
 *   - ELB
 *   - EC2
 *
 *   @see-also: http://docs.aws.amazon.com/cli/latest/reference/autoscaling/create-auto-scaling-group.html#options
 */
variable "health_check_type" {
  description = "The health check used by the ASG to determine health; this is auto calculated; you can override it by defining it to eihter EC2 or ELB"
  default     = ""
}

// `false` if you don't want to attach this autoscaling group to an ELB (from load_balancer_names)
variable "enable_elb" {
  default = "true"
}

variable "load_balancer_names" {
  description = "A comma separated list string of ELB names the ASG should associate instances with"
  default     = ""
}

variable "availability_zones" {
  description = "Deprecated; use vpc_zone_subnets for specifying where to run the instances; keeping it here empty for compatibility with old code"
  default     = ""
}

variable "vpc_zone_subnets" {
  description = "A comma separated list string of VPC subnets to associate with ASG"
}

// We use this hack to detect the vpc_id we are running in and not ask for it.
data "aws_subnet" "primary_subnet" {
  id = "${element(split(",", var.vpc_zone_subnets), 0)}"
}

variable "tags" {
  type    = "list"
  default = []
}

variable "target_groups" {
  type    = "list"
  default = []
}

variable "environment" {
  description = "AWS Environment tag, example 'dev', 'stage' or 'prod'. Defaults to 'unknown'"
  default     = "unknown"
}

variable "team" {
  description = "AWS tag 'Team' used to associate with an ADC team, E.g. 'adc-sre', 'adc-datascience' or 'trinity'"
  default     = "unknown"
}

variable "role" {
  description = "AWS tag 'Role' used to associate with a role the service takes part in, example 'worker' or 'cron', A role should be more general and covers multiple services"
  default     = "unknown"
}

variable "service" {
  description = "AWS tag 'Service' used to associate with a role the service takes part in, example 'importer' or 'exporter' or 'frontend-api', basically a subset of the role tag"
  default     = "unknown"
}

variable "description" {
  description = "Friendly description of the component and its use"
  default     = "unknown"
}

variable "owner" {
  description = "team/contact email address"
  default     = "unknown"
}

variable "product" {
  description = "name of the product which the service belongs"
  default     = "unknown"
}

variable "offhours" {
  description = "Tag used for automatically turning on/off asgs during offhours"
  default     = "off"
}

variable "root_volume_type" {
  description = "Root block device size"
  default     = "gp2"
}

variable "root_volume_size" {
  description = "Root block device type"
  default     = 8
}

variable "root_volume_iops" {
  description = "Root iops to provision to root volume, optional used for io1 type volumes"
  default     = "200"
}

// `true` if you are attaching this autoscaling group to an Application Load
// Balancer (ALB).
variable "enable_alb" {
  type    = "string"
  default = "false"
}

// `true` if you are attaching this autoscaling group to a Network Load
// Balancer (NLB).
variable "enable_nlb" {
  type    = "string"
  default = "false"
}

// The ARN Application Load Balancer (ALB) Listner to attach this ASG
// to. If you are not using ALB or will be attaching outside of the module,
// do not specify this value.
variable "alb_listener_arn" {
  type    = "string"
  default = ""
}

// The rule number for the ALB attachment. This rule cannot conflict with
// other attachments.
variable "alb_rule_number" {
  type    = "string"
  default = "100"
}

// A list of URIs to attach to the ALB as target rules, if one is specified.
variable "alb_path_patterns" {
  type    = "list"
  default = ["/*"]
}

// The service port that the ASG will be listening on for ALB attachments.
variable "alb_service_port" {
  type    = "string"
  default = "80"
}

// The health check URI to add as the ALB health check.
variable "alb_health_check_uri" {
  type    = "string"
  default = "/"
}

// The time to wait before marking the ALB health check as failed. Note that
// this number needs to be lower than health_check_interval.
variable "alb_health_check_timeout" {
  type    = "string"
  default = "3"
}

// The time to wait between ALB health checks. Note that this
// number needs to be lower than health_check_timeout.
variable "alb_health_check_interval" {
  type    = "string"
  default = "10"
}

// The time to wait before marking the ALB health check as failed. Note that
// this number needs to be lower than health_check_interval.
variable "alb_health_check_port" {
  type    = "string"
  default = "traffic-port"
}

// The ALB target protocol. Can be one of HTTP or HTTPS.
variable "alb_target_protocol" {
  type    = "string"
  default = "HTTP"
}

// The LB stickiness expiration period. This configures LB stickiness, aka
// session persistence, on the side of the load balancer. Use when the
// application is not LB-aware on its own. When not specified, the default
// value is 1 second. Note that zero or negative values will result in an
// error.
variable "alb_stickiness_duration" {
  type    = "string"
  default = ""
}

// The service port that the ASG will be listening on for NLB attachments.
variable "nlb_service_port" {
  type    = "string"
  default = "80"
}

// The time to wait between NLB health checks. Note that this
// number needs to be lower than health_check_timeout.
variable "nlb_health_check_timeout" {
  type    = "string"
  default = "3"
}

// The time to wait before marking the NLB health check as failed. Note that
// this number needs to be lower than health_check_interval.
variable "nlb_health_check_interval" {
  type    = "string"
  default = "10"
}

// The time to wait before marking the NLB health check as failed. Note that
// this number needs to be lower than health_check_interval.
variable "nlb_health_check_port" {
  type    = "string"
  default = "6233"
}

// The NLB target protocol. Can be one of HTTP or HTTPS.
variable "nlb_target_protocol" {
  type    = "string"
  default = "TCP"
}

// Works for ALB, ELB but not for NLB, must be false for NLB
variable "enable_stickiness" {
  type    = "string"
  default = "true"
}
