# Set up your development environment.

## Code editor
Like most development environments Terraform is completely text based.  Therefore you will need a text editor.  In this class we'll be using Microsoft VSCode.

Install:
    <details>
    <summary>Windows</summary>
        https://code.visualstudio.com/docs/setup/windows
    </details>
    <details>
    <summary>MacOS</summary>
        https://code.visualstudio.com/docs/setup/mac
    </details>
    <details>
    <summary>Linux</summary>
        https://code.visualstudio.com/docs/setup/linux
    </details>

Plugins can be installed from the VSCode Marketplace, or from within VSCode itself. 
    
- [Hashicorp HCL](https://marketplace.visualstudio.com/items?itemName=HashiCorp.HCL)
- [Hashicorp Terraform](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)

> 📘 There are other plugins available for Terraform development, but these are the official Hashicorp versions.

## Other tools.
There is an ecosystem of tools to help develop Terraform code.  We'll be using a few of these, but they're all worth checking out.

| [ checkov ]( https://checkov.io )                                                               | IaC policy checker                            |
|-------------------------------------------------------------------------------------------------|-----------------------------------------------|
| [ cloud-nuke ]( https://github.com/gruntwork-io/cloud-nuke )                                    | Destroyer of clouds.                          |
| [ graphviz ]( https://graphviz.org/ )                                                           | Graph visualizer                              |
| [ gnu-make ]( https://www.gnu.org/software/make/ )                                              | Makefile processor                            |
| [ pre-commit ]( https://pre-commit.com/ )                                                       | Pre-commit static analysis                    |
| [ terraform-docs ]( https://terraform-docs.io/ )                                                | Automatic documentation for Terraform modules |
| [ tfenv ]( https://github.com/tfutils/tfenv )                                                   | Terraform version manager                     |
| [ tflint ]( https://github.com/terraform-linters/tflint )                                       | Terraform linter                              |
| [ m1-terraform-provider-helper ]( https://github.com/kreuzwerker/m1-terraform-provider-helper ) | For m1 Mac compat                             |

> 📘 These can be installed on systems that support [Homebrew](https://brew.sh/) (MacOS, Linux, WSL).

## Install Terraform
Even though you have installed a lot of tools, Terraform itself is not installed yet.
To install it run:

`tfenv install latest`

> 🚧 tfenv may not work on Windows.  Instead you can download terraform binaries here: https://www.terraform.io/downloads

Now that Terraform is installed you can begin exploring it.

Try `terraform help` to see what commands are available.

Run `terraform apply`  What happens?
> 📘 We'll be exploring a lot of these in detail throughout the course, but feel free to ask if any commands pique your interest.

> 📘 typing `terraform` at the prompt gets tedious quickly.  Try adding an alias `tf=terraform` using your shell's aliasing mechanism.

## Check your AWS settings.
> 📘 A full walk through of setting up AWS accounts is outside the scope of the training, but you should be able to run:

`aws sts get-caller-identity`

to verify it's configured as you expect.
