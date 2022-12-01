# Provisioner blocks
# Used to configure resources after creation.
# Example:
#   SSH into ec2 instance and configure a web server.
# Provisioners are seldom used now.
# use provisioners as a last resort. See: https://www.terraform.io/language/resources/provisioners/syntax

# The most common use case for provisioners is executing miscellaneous scripts.
resource "null_resource" "mkdir" {
  provisioner "local-exec" {
    command = "mkdir -p ${self.id}"
    #interpreter = ["/bin/bash", "-c"]
    #working_dir = "~"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${self.id}"
  }
}
