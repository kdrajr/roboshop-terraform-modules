locals {
  common_name_prefix = "${var.project_name}-${var.environment}"
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  private_subnet_ids = split("," , data.aws_ssm_parameter.private_subnet_ids.value)
  backend-alb_sg_id = data.aws_ssm_parameter.backend-alb_sg_id.value
  public_subnet_ids = split("," , data.aws_ssm_parameter.public_subnet_ids.value)
  frontend-alb_sg_id = data.aws_ssm_parameter.frontend-alb_sg_id.value
  zone_id = data.aws_route53_zone.sniggie.zone_id

  lb_sg_id = var.is_it_internal == true ? local.backend-alb_sg_id : local.frontend-alb_sg_id
  subnets = var.is_it_internal == true ? local.private_subnet_ids : local.public_subnet_ids
  lb_name_suffix = var.is_it_internal == true ? "backend-alb" : "frontend-alb"
  listener_port = var.is_it_internal == true ? 80 : 443
  listener_protocol = var.is_it_internal == true ? "HTTP" : "HTTPS"
  listener_ssl_policy = var.is_it_internal == true ? null : "ELBSecurityPolicy-TLS13-1-3-2021-06"
  listener_cert_arn = var.is_it_internal == true ? null : data.aws_ssm_parameter.frontend-alb_cert_arn.value
  dns_record_name = var.is_it_internal == true ? "*.backend-alb-${var.environment}.${var.domain_name}" : "roboshop-${var.environment}.${var.domain_name}"


  common_tags = {
    Project = var.project_name
    Environment = var.environment
    Terraform = "true"
  }
}