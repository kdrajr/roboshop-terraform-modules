variable "is_it_internal" {
  type = bool
}

variable "lb_type" {
  type = string
  default = "application"
}

variable "lb_sg_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list
}

variable "public_subnet_ids" {
  type = list
}

variable "enable_deletion_protection" {
  default = true
}

variable "lb_name_suffix" {
  type = string
}

variable "project_name" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "lb_tags" {
  default = {}
}

variable "domain_name" {
  default = "sniggie.fun"
}

variable "zone_id" {
  type = string
}