locals {
  #ami_id = data.aws_ami.devops.id
  db-component_sg_id = data.aws_ssm_parameter.db-component_sg_id.value
  database_subnet_id = split(",", data.aws_ssm_parameter.database_subnet_ids.value)[0]
  ec2-user_pass = data.aws_ssm_parameter.ec2-user_pass.value
  zone_id = data.aws_route53_zone.sniggie.zone_id

  iam_instance_profile = var.db-component == "mysql" ? "Ec2SSMParameterRead" : null
  
  common_name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project = var.project_name
    Environment = var.environment
    Terraform = "true"
  }
}