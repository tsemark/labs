locals {
  user_data = file("${path.module}/user-data.sh")

  public_subnets = aws_subnet.public[*].id
}


resource "aws_instance" "app" {
  count = var.instance_count

  ami           = var.ami_id
  instance_type = var.instance_type

  key_name               = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id              = local.public_subnets[count.index % length(local.public_subnets)]

  associate_public_ip_address = true

  user_data = local.user_data

  tags = {
    Name = "${var.project_name}-app-${count.index + 1}"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
  }
}

