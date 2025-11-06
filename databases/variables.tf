variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "db-component" {
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
