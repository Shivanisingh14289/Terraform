resource "aws_security_group" "ec2_sg" {
  count = var.instance_count

  name        = element(var.name, count.index)
  description = "Security group for EC2 instance ${count.index}"
  vpc_id      = var.vpc_id
}

resource "aws_instance" "ec2_instance" {
  count = var.instance_count

  ami           = element(var.ami_id, count.index)
  instance_type = element(var.instance_type, count.index)
  subnet_id     = var.subnet_id

  associate_public_ip_address = false

  security_groups = [aws_security_group.ec2_sg[count.index].name]
  tags = {
    Name = element(var.name, count.index)
  }
}
