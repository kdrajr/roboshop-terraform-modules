resource "aws_lb" "main" {
  name               = "${local.common_name_prefix}-${local.lb_name_suffix}"
  internal           = var.is_it_internal
  load_balancer_type = var.lb_type
  security_groups    = [local.lb_sg_id]
  subnets            = local.subnets

  enable_deletion_protection = var.enable_deletion_protection


  tags = merge(
    var.lb_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${local.lb_name_suffix}"
    }
  )
}


resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = local.listener_port
  protocol          = local.listener_protocol

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hello, I am from ${local.common_name_prefix}-${local.lb_name_suffix}"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "main" {
  zone_id = local.zone_id
  name    = local.dns_record_name
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}


