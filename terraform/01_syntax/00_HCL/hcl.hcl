# Generic HCL syntax
type "label1" "label2" {
    block {
        attribute = "value"
    }
    attribute = "string value"
    attribute = true # bool
    attribute = ["list"]
    attribute = {
        map = true
    }
}

# Other HCL implementations

## Packer
packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:xenial"
  commit = true
}

build {
  name    = "learn-packer"
  sources = [
    "source.docker.ubuntu"
  ]
}

# Terragrunt
include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/webserver-cluster.hcl"
}

inputs = {
  instance_type = "t2.medium"

  min_size = 3
  max_size = 3
}