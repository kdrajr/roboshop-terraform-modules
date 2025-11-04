resource "aws_lb" "lb" {
  name               = "${local.common_name_prefix}-${var.lb_name_suffix}"
  internal           = var.is_it_internal
  load_balancer_type = var.lb_type
  security_groups    = [var.lb_sg_id]
  subnets            = var.is_it_internal == true ? var.private_subnet_ids : var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection


  tags = merge(
    var.lb_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.lb_name_suffix}"
    }
  )
}


resource "aws_lb_listener" "lb" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hello, I am from ${local.common_name_prefix}-${var.lb_name_suffix}"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "lb" {
  zone_id = var.zone_id
  name    = var.is_it_internal == true ? "*.backend-alb-${var.environment}.${var.domain_name}" : "${var.environment}.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}


