variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "component" {
  type = string
}

variable "ec2-user_pass" {
  type = string
}

variable "asg_desired_capacity" {
  type = number
}

variable "asg_max_size" {
  type = number
}

variable "asg_min_size" {
  type = number
}

variable "rule_priority" {
  type = number
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



