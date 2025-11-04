variable "vpc_id" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "component" {
  type = string
}


variable "component_sg_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list
}

variable "ec2-user_pass" {
  type = string
}

variable "backend-alb_listener_arn" {
  type = string
}

variable "project_name" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "domain_name" {
  default = "sniggie.fun"
}

variable "ec2_tags" {
  default = {}
}

variable "volume_tags" {
  default = {}
}



