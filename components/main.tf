resource "aws_instance" "main" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [local.component_sg_id]
  subnet_id = local.private_subnet_id
  iam_instance_profile = local.iam_instance_profile

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.component}"
    }
  )
}


resource "terraform_data" "main" {
  triggers_replace =  [aws_instance.main.id]
    
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = var.ec2-user_pass
    host     = aws_instance.main.private_ip
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

resource "aws_ec2_instance_state" "main" {
  instance_id = aws_instance.main.id
  state       = "stopped"

  depends_on = [terraform_data.main]
}

resource "aws_ami_from_instance" "main" {
  name               = "${local.common_name_prefix}-${var.component}-ami"
  source_instance_id = aws_instance.main.id

  depends_on = [aws_ec2_instance_state.main]

  /* provisioner "local-exec" {
      command = "aws ec2 terminate-instances --instance-ids ${aws_instance.main.id}"
    } */

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.component}-ami"
    }
  )
}


resource "aws_ec2_instance_state" "main" {
  instance_id = aws_instance.main.id
  state       = "running"

  depends_on = [aws_ami_from_instance.main]
}

resource "aws_launch_template" "main" {
  name = "${local.common_name_prefix}-${var.component}"
  image_id = aws_ami_from_instance.main.id
  instance_type = var.instance_type
  instance_initiated_shutdown_behavior = "terminate"
  vpc_security_group_ids = [local.component_sg_id]
  update_default_version = true

### tags for launched instance with this template
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

### tags for volume created with this template
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

### tags for this template
  tags = merge(
      local.common_tags,
      {
        Name = "${local.common_name_prefix}-${var.component}"
      }
  )

}


resource "aws_lb_target_group" "main" {
  name     = "${local.common_name_prefix}-${var.component}"
  port     = local.tg_port
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 60

  health_check {
    path = local.tg_health_check_path
    protocol = "HTTP"
    port = local.tg_port
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

resource "aws_autoscaling_group" "main" {
  name = "${local.common_name_prefix}-${var.component}"
  desired_capacity   = var.asg_desired_capacity
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size
  vpc_zone_identifier = local.private_subnet_ids
  force_delete = false
  health_check_type = "ELB"
  health_check_grace_period = 100
  target_group_arns = [aws_lb_target_group.main.arn]
  

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  timeouts {
    delete = "15m"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
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

resource "aws_autoscaling_policy" "main" {
  name = "${local.common_name_prefix}-${var.component}"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }

}



resource "aws_lb_listener_rule" "alb_component" {
  listener_arn = local.lb_listener_arn
  priority = var.rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = [local.host_header_value]
    }
  }

  tags = {
    Name = "${local.common_name_prefix}-${var.component}"
  }
}




/* resource "terraform_data" "terminate_component_instance" {
    triggers_replace = [aws_instance.main.id]

    provisioner "local-exec" {
      command = "aws ec2 terminate-instances --instance-ids ${aws_instance.main.id}"
    }
    depends_on = [aws_autoscaling_policy.main]
} */



