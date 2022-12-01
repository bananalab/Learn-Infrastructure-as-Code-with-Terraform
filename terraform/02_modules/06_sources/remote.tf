# Providers don't have to be in the local filesystem.

# Terraform public registry
module "public_registry" {
  source  = "rojopolis/repo-index/helm"
  version = "0.1.0"
  dir     = ""
}

# Terraform private registry
/*
module "private_registry" {
  source  = "app.terraform.io/bananalab/repo-index/helm"
  version = "0.1.0"
  dir     = ""
}
*/

module "github" {
  source = "github.com/rojopolis/terraform-helm-repo-index?ref=0.1.0"
  dir    = ""
}

module "generic_git_https" {
  source = "git::https://github.com/rojopolis/terraform-helm-repo-index.git?ref=0.1.0"
  dir    = ""
}

module "generic_git_ssh" {
  source = "git::git@github.com:rojopolis/terraform-helm-repo-index.git?ref=0.1.0"
  dir    = ""
}


module "github_monorepo" {
  source = "github.com/bananalab/terraform-modules//modules/aws-s3-bucket?ref=v0.1.0"

}

module "generic_git_ssh" {
  source = "git::git@github.com/bananalab/terraform-modules.git//modules/aws-s3-bucket?ref=v0.1.0"

}
