terraform {
    required_version = "~> 0.12.0"
    backend "remote"{
        hostname     = "app.terraform.io"
        organization = "rojopolis"
        workspaces {
            name = "collaboration"
        }
    }
}