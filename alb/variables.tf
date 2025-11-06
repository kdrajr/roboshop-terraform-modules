variable "is_it_internal" {
  type = bool
}

variable "lb_type" {
  type = string
  default = "application"
}


variable "enable_deletion_protection" {
  default = true
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