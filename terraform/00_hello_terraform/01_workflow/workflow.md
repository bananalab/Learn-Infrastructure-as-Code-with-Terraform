# Terraform Workflow
The core Terraform workflow consists of 3 phases:

1. Write

     Infrastructure code is written in Terraform's DSL called Hashicorp
     configuration Language (HCL).

2. Initialize

     Before Terraform can run it must download its dependencies.

3. Plan

     Before Terraform modifies resources it creates an action plan outlining
     changes required.

4. Apply

     Becuase Terraform uses a declarative model changes are applied rather
     than executed.

Try it:

Create a file named `workflow.tf` in this directory and add this text:

```bash
    resource "aws_s3_bucket" "bucket" {}
```

Now run `terraform plan`

<br/><br/>
<br/><br/>

>Initialization:
>
>  Before the Plan and Apply phases you must initialize terraform by running:
>  ```
>  terraform init
> ```
>
>  Try it:
>
>  Run the above command in this directory.  What happens?
>
>  Now create an empty file in the same directory named `workflow.tf` and run `terraform init` again.

Next run `terraform apply`

<br/><br/>
<br/><br/>


Explore the filesystem:

What files did Terraform create?
<br/><br/>
<br/><br/>
Clean up:

run `terraform destroy`