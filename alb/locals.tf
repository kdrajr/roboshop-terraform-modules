locals {
  common_name_prefix = "${var.project_name}-${var.environment}"
  /* vpc_id             = data.aws_ssm_parameter.vpc_id.value
  private_subnet_ids = split("," , data.aws_ssm_parameter.private_subnet_ids.value)
  backend-alb_sg_id = data.aws_ssm_parameter.backend-alb_sg_id.value */
  zone_id = data.aws_route53_zone.sniggie.zone_id
  common_tags = {
    Project = var.project_name
    Environment = var.environment
    Terraform = "true"
  }
}