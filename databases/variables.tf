variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "db" {
  type = string
}

variable "db_sg_id" {
  type = string
}

variable "database_subnet_id" {
  type = string
}

variable "ec2-user_pass" {
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

variable "zone_id" {
  type = string
}

variable "db" {
  type = string
}

variable "ec2_tags" {
  default = {}
}
