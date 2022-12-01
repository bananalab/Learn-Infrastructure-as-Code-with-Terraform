# Refactoring Terraform.

Somtimes Terraform code needs to evolve to grow.  Terraform provides some tools to help with this.

1. The `moved` block.
    Within a terraform config you can specify the new path for an object:
    ```
    moved {
        <old.path>
        <new.path>
    }
    ```
2. The command `terraform state mv`

Try refactoring your imported code into mutiple state files or multiple modules (or both).
