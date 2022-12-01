# Continuous Deployment and Terraform

When running Terraform in production it's wise to use a continuous delivery system to ensure consistency.

A good open source option is [Atlantis](https://www.runatlantis.io/).  Atlantis interacts with various Git providers by hooking into the collaborations features (Pull Request).

# Set up Atlantis

Follow the instructions [here](https://www.runatlantis.io/guide/testing-locally.html) to set up Atlantis for local testing.

The Webhook should be configured in the `terraform-live` repo you created previously.

Modify the code in `terraform-live` and push it to Github.  What happens?