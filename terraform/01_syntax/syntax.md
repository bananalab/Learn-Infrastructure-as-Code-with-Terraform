# Dynamic blocks

In this project you will create dynamically set up blocks.

Typical code of security group looks like the example below:

```tf
resource "aws_security_group" "main" {
   name   = "resource_without_dynamic_block"
   vpc_id = data.aws_vpc.main.id

   ingress {
      description = "ingress_rule_1"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
   
   ingress {
      description = "ingress_rule_2"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "AWS security group non-dynamic block"
   }
}
```

The **ingress** is a block. It can be repeated multiple times, however it is possible to do it dynamically by using variables that are lists or maps.

## Project "security group"

1. Create the directory for the project:

    ```bash
    mkdir dynamic && cd dynamic
    ```

1. Create files for the project:

    * `main.tf`
    * `variables.tf`
    * `providers.tf`

1. Set up AWS provider in the `providers.tf` file.
1. In the `main.tf`, create a VPC resource called `vpc`.
1. In `variables.tf`, add a variable for the ports that the security group would allow:

    ```tf
    variable "rules" {
      type = list  
      default = [{
        port        = 443
        description = "Ingress for HTTPS"
        cidr        = "0.0.0.0/0"
      },
      {
        port        = 80
        description = "Ingress for HTTP"
        cidr        = "0.0.0.0/0"
      }]
    }
    ```

1. In `main.tf`, add a security group resource that dynamically sets up ingress blocks.

    ```tf
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
    ```

