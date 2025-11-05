resource "aws_instance" "component" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [var.component_sg_id]
  subnet_id = var.private_subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.component}"
    }
  )
}


resource "terraform_data" "component" {
  triggers_replace =  [aws_instance.component.id]
    
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = var.ec2-user_pass
    host     = aws_instance.component.private_ip
  }

  provisioner "file" {
  source      = "component.sh"
  destination = "/tmp/component.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/component.sh",
      "sudo sh /tmp/component.sh ${var.component} ${var.environment}"

    ]
  }
}

resource "aws_ec2_instance_state" "component" {
  instance_id = aws_instance.component.id
  state       = "stopped"

  depends_on = [terraform_data.component]
}

resource "aws_ami_from_instance" "component" {
  name               = "${local.common_name_prefix}-${var.component}-ami"
  source_instance_id = aws_instance.component.id

  depends_on = [aws_ec2_instance_state.component]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.component}-ami"
    }
  )
}

resource "aws_launch_template" "component" {
  name = "${local.common_name_prefix}-${var.component}"
  image_id = aws_ami_from_instance.component.id
  instance_type = var.instance_type
  instance_initiated_shutdown_behavior = "terminate"
  vpc_security_group_ids = [var.component_sg_id]


  tag_specifications {
    resource_type = "instance"

    tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.component}"
    }
  )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
    var.volume_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.component}"
    }
  )
  }

  tags = merge(
      local.common_tags,
      {
        Name = "${local.common_name_prefix}-${var.component}"
      }
  )

}


resource "aws_lb_target_group" "component" {
  name     = "${local.common_name_prefix}-${var.component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  deregistration_delay = 60

  health_check {
    path = "/health"
    protocol = "HTTP"
    port = 8080
    matcher = "200-299"
    interval = 10
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 3
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.component}"
    }
  )
}

resource "aws_autoscaling_group" "component" {
  name = "${local.common_name_prefix}-${var.component}"
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  vpc_zone_identifier = var.private_subnet_ids
  health_check_type = "ELB"
  health_check_grace_period = 60
  target_group_arns = [aws_lb_target_group.component.arn]
  

  launch_template {
    id      = aws_launch_template.component.id
    version = aws_launch_template.component.latest_version
  }

  timeouts {
    delete = "15m"
  }

  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name = "${local.common_name_prefix}-${var.component}"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true      
    }
  }
}

resource "aws_autoscaling_policy" "component" {
  name = "${local.common_name_prefix}-${var.component}"
  autoscaling_group_name = aws_autoscaling_group.component.name
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }

}



resource "aws_lb_listener_rule" "backend_component" {
  listener_arn = var.backend-alb_listener_arn
  priority = var.rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.component.arn
  }

  condition {
    host_header {
      values = ["${var.component}.backend-alb-${var.environment}.${var.domain_name}"]
    }
  }

  tags = {
    Name = "${local.common_name_prefix}-${var.component}"
  }
}


resource "terraform_data" "terminate_component_instance" {
    triggers_replace = [aws_instance.component.id]

    provisioner "local-exec" {
      command = "aws ec2 terminate-instances --instance-ids ${aws_instance.component.id}"
    }
    depends_on = [aws_autoscaling_policy.component]
}



