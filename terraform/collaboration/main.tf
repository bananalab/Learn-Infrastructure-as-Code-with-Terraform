terraform {
  required_version = "~> 1.2.0"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "bananalab"
    workspaces {
      name = "collaboration"
    }
  }
}

resource "random_pet" "name" {}
output "pet_name" { value = random_pet.name.id }
