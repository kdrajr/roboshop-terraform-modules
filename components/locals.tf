locals {
  #ami_id = data.aws_ami.devops.id
  vpc_id  = data.aws_ssm_parameter.vpc_id.value
  component_sg_id = data.aws_ssm_parameter.component_sg_id.value
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]
  public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
  backend-alb_listener_arn = data.aws_ssm_parameter.backend-alb_listener_arn.value
  frontend-alb_listener_arn = data.aws_ssm_parameter.frontend-alb_listener_arn.value
  ec2-user_pass = data.aws_ssm_parameter.ec2-user_pass.value
  zone_id = data.aws_route53_zone.sniggie.zone_id

  subnet_id = "${var.component}" == "frontend" ? local.public_subnet_id : local.private_subnet_id
  tg_port = "${var.component}" == "frontend" ? 80 : 8080
  tg_health_check_path = "${var.component}" == "frontend" ? "/" : "/health"
  vpc_zone_identifier = "${var.component}" == "frontend" ? local.public_subnet_ids : local.private_subnet_ids
  lb_listener_arn = "${var.component}" == "frontend" ? local.frontend-alb_listener_arn : local.backend-alb_listener_arn
  host_header_value = "${var.component}" == "frontend" ? "${var.environment}.${var.domain_name}" : "${var.component}.backend-alb-${var.environment}.${var.domain_name}"
  
  common_name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project = var.project_name
    Environment = var.environment
    Terraform = "true"
  }
}