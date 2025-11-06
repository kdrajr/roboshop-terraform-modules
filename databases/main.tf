resource "aws_instance" "main" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [local.db-component_sg_id]
  subnet_id = local.database_subnet_id
  iam_instance_profile = local.iam_instance_profile

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${local.common_name_prefix}-${var.db-component}"
    }
  )
}

resource "aws_route53_record" "main" {
  zone_id = local.zone_id
  name    = "${var.db-component}-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.main.private_ip]
  allow_overwrite = true
}

resource "terraform_data" "main" {
  triggers_replace =  [aws_instance.main.id]
    
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = local.ec2-user_pass
    host     = aws_instance.main.private_ip
  }

  provisioner "file" {
  source      = "bootstrap.sh"
  destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh ${var.db-component} ${var.environment}"

    ]
  }
}









/* 
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








