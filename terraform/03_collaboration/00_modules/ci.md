# Continuous integration with Terraform.

Terraform is testable!  Normally only reusable modules are tested (not root configs).

The leading testing library for Terraform is [Terratest](https://terratest.gruntwork.io/)

Terratest uses the Go test framework and provides classes specific to Terraform.

Look in the `tests` directory in your modules.

You can run the tests with `make test` inside your module's directory (e.g. modules/aws-s3-bucket).

These tests are run in Github Actions when code is pushed to the modules repo.

# Check it out.
Push your module to your repo and look for the yellow or green dot.  Is there a red X?  

Can you get your test to pass?

Make changes to your module and check that tests still pass.

Try setting your repo to require passing tests before merging pull requests.
