resource "aws_instance" "db" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [var.db_sg_id]
  subnet_id = var.database_subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.db}"
    }
  )
}

resource "aws_route53_record" "db" {
  zone_id = var.zone_id
  name    = "${var.db}-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.db.private_ip]
  allow_overwrite = true
}

resource "terraform_data" "db" {
  triggers_replace =  [aws_instance.db.id]
    
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = var.ec2-user_pass
    host     = aws_instance.db.private_ip
  }

  provisioner "file" {
  source      = "bootstrap.sh"
  destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh ${var.db} ${var.environment}"

    ]
  }
}








#### redis server setup
/* resource "aws_instance" "redis" {
  ami = local.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [local.redis_sg_id]
  subnet_id = local.db_subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-redis"
    }
  )
}

resource "aws_route53_record" "redis" {
  zone_id = local.zone_id
  name    = "redis-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.redis.private_ip]
  allow_overwrite = true
}

resource "terraform_data" "redis" {
  triggers_replace =  [aws_instance.redis.id]
    
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = local.ec2-user_pass
    host     = aws_instance.redis.private_ip
  }

  provisioner "file" {
  source      = "bootstrap.sh"
  destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh redis dev"

    ]
  }
}


### rabbitmq server setup
resource "aws_instance" "rabbitmq" {
  ami = local.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [local.rabbitmq_sg_id]
  subnet_id = local.db_subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-rabbitmq"
    }
  )
}

resource "aws_route53_record" "rabbitmq" {
  zone_id = local.zone_id
  name    = "rabbitmq-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.rabbitmq.private_ip]
  allow_overwrite = true
}

resource "terraform_data" "rabbitmq" {
  triggers_replace =  [aws_instance.rabbitmq.id]
    
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = local.ec2-user_pass
    host     = aws_instance.rabbitmq.private_ip
  }

  provisioner "file" {
  source      = "bootstrap.sh"
  destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh rabbitmq dev"

    ]
  }
}


###  mysql server setup
resource "aws_instance" "mysql" {
  ami = local.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [local.mysql_sg_id]
  subnet_id = local.db_subnet_id
  iam_instance_profile = aws_iam_instance_profile.mysql.name

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-mysql"
    }
  )
}

resource "aws_route53_record" "mysql" {
  zone_id = local.zone_id
  name    = "mysql-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.mysql.private_ip]
  allow_overwrite = true
}

resource "terraform_data" "mysql" {
  triggers_replace =  [aws_instance.mysql.id]
    
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = local.ec2-user_pass
    host     = aws_instance.mysql.private_ip
  }

  provisioner "file" {
  source      = "bootstrap.sh"
  destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mysql dev"

    ]
  }
}

resource "aws_iam_instance_profile" "mysql" {
  name = "mysql"
  role = "Ec2SSMParameterRead"
}


 */








#### create db servers and Perform post-apply operations with terraform_data, provisioners using count based loops  ####
/* resource "aws_instance" "db" {
  count = length(var.db)
  ami = local.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [local.db[count.index]_sg_id]
  subnet_id = local.db_subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.db[count.index]}"
    }
  )
}

resource "aws_route53_record" "db" {
  count = length(var.db)
  zone_id = local.zone_id
  name    = "${var.db}-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.db[count.index].private_ip]
  allow_overwrite = true
}

resource "terraform_data" "db" {
  count = length(var.db)
  triggers_replace =  [aws_instance.db[count.index].id]
    
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = local.ec2-user_pass
    host     = aws_instance.db[count.index].private_ip
  }

  provisioner "file" {
  source      = "bootstrap.sh"
  destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh ${var.db[count.index]} ${var.environment}"

    ]
  }
} */