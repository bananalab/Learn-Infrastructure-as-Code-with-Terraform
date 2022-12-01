resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_security_group" "main" {
  name   = "resource_with_dynamic_block"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = toset(var.rules)

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
    }
  }

  tags = {
    Name = "AWS security group dynamic block"
  }
}
