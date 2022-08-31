workflow "Terraform" {
  resolves = ["terraform-apply-api-deployment"]
  on = "pull_request"
}

action "Debug" {
  uses = "actions/bin/sh@master"
  args = ["env"]
}

action "filter-to-pr-open-synced" {
  uses = "actions/bin/filter@master"
  args = "action 'opened|synchronize'"
}

action "terraform-init-cognito" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.4"
  needs = "filter-to-pr-open-synced"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/cognito/user_pool"
  }
}

action "terraform-validate-cognito" {
  uses = "hashicorp/terraform-github-actions/validate@v0.3.4"
  needs = "terraform-init-cognito"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/cognito/user_pool"
  }
}

action "terraform-plan-cognito" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-validate-cognito"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["-out", "plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/cognito/user_pool"
  }
}

action "terraform-apply-cognito" {
  uses = "hashicorp/terraform-github-actions/apply@v0.3.4"
  needs = "terraform-plan-cognito"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/cognito/user_pool"
  }
}

action "terraform-init-dynamodb" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.4"
  needs = "filter-to-pr-open-synced"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/dynamodb"
  }
}

action "terraform-validate-dynamodb" {
  uses = "hashicorp/terraform-github-actions/validate@v0.3.4"
  needs = "terraform-init-dynamodb"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/dynamodb"
  }
}

action "terraform-workspace-dynamodb" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-validate-dynamodb"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  runs = ["sh", "-c", "cd $TF_ACTION_WORKING_DIR; terraform workspace select $GITHUB_HEAD_REF || terraform workspace new $GITHUB_HEAD_REF"]
  env = {
    TF_ACTION_WORKING_DIR = "app/dynamodb"
  }
}

action "terraform-plan-dynamodb" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-workspace-dynamodb"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["-out", "plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/dynamodb"
  }
}

action "terraform-apply-dynamodb" {
  uses = "hashicorp/terraform-github-actions/apply@v0.3.4"
  needs = "terraform-plan-dynamodb"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/dynamodb"
  }
}

action "terraform-init-sqs" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.4"
  needs = "filter-to-pr-open-synced"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/sqs"
  }
}

action "terraform-validate-sqs" {
  uses = "hashicorp/terraform-github-actions/validate@v0.3.4"
  needs = "terraform-init-sqs"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/sqs"
  }
}

action "terraform-workspace-sqs" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-validate-sqs"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  runs = ["sh", "-c", "cd $TF_ACTION_WORKING_DIR; terraform workspace select $GITHUB_HEAD_REF || terraform workspace new $GITHUB_HEAD_REF"]
  env = {
    TF_ACTION_WORKING_DIR = "app/sqs"
  }
}

action "terraform-plan-sqs" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-workspace-sqs"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["-out", "plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/sqs"
  }
}

action "terraform-apply-sqs" {
  uses = "hashicorp/terraform-github-actions/apply@v0.3.4"
  needs = "terraform-plan-sqs"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/sqs"
  }
}

action "terraform-init-kms" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.4"
  needs = "filter-to-pr-open-synced"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/kms"
  }
}

action "terraform-validate-kms" {
  uses = "hashicorp/terraform-github-actions/validate@v0.3.4"
  needs = "terraform-init-kms"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/kms"
  }
}

action "terraform-workspace-kms" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-validate-kms"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  runs = ["sh", "-c", "cd $TF_ACTION_WORKING_DIR; terraform workspace select $GITHUB_HEAD_REF || terraform workspace new $GITHUB_HEAD_REF"]
  env = {
    TF_ACTION_WORKING_DIR = "app/kms"
  }
}

action "terraform-plan-kms" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-workspace-kms"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["-out", "plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/kms"
  }
}

action "terraform-apply-kms" {
  uses = "hashicorp/terraform-github-actions/apply@v0.3.4"
  needs = "terraform-plan-kms"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/kms"
  }
}

action "terraform-init-lambda" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.4"
  needs = ["terraform-apply-kms", "terraform-apply-dynamodb", "terraform-apply-sqs", "terraform-apply-cognito",]
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/lambda"
  }
}

action "terraform-validate-lambda" {
  uses = "hashicorp/terraform-github-actions/validate@v0.3.4"
  needs = "terraform-init-lambda"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/lambda"
  }
}

action "terraform-workspace-lambda" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-validate-lambda"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  runs = ["sh", "-c", "cd $TF_ACTION_WORKING_DIR; terraform workspace select $GITHUB_HEAD_REF || terraform workspace new $GITHUB_HEAD_REF"]
  env = {
    TF_ACTION_WORKING_DIR = "app/lambda"
  }
}

action "terraform-plan-lambda" {
  #uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  uses = "./cicd/plan"
  needs = "terraform-workspace-lambda"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["-out", "plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/lambda"
  }
}

action "terraform-apply-lambda" {
  uses = "hashicorp/terraform-github-actions/apply@v0.3.4"
  needs = "terraform-plan-lambda"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/lambda"
  }
}

action "terraform-init-cloudwatch" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.4"
  needs = ["terraform-apply-lambda"]
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/cloudwatch"
  }
}

action "terraform-validate-cloudwatch" {
  uses = "hashicorp/terraform-github-actions/validate@v0.3.4"
  needs = "terraform-init-cloudwatch"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/cloudwatch"
  }
}

action "terraform-workspace-cloudwatch" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-validate-cloudwatch"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  runs = ["sh", "-c", "cd $TF_ACTION_WORKING_DIR; terraform workspace select $GITHUB_HEAD_REF || terraform workspace new $GITHUB_HEAD_REF"]
  env = {
    TF_ACTION_WORKING_DIR = "app/cloudwatch"
  }
}

action "terraform-plan-cloudwatch" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-workspace-cloudwatch"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["-out", "plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/cloudwatch"
  }
}

action "terraform-apply-cloudwatch" {
  uses = "hashicorp/terraform-github-actions/apply@v0.3.4"
  needs = "terraform-plan-cloudwatch"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/cloudwatch"
  }
}

action "terraform-init-rest-api" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.4"
  needs = ["terraform-apply-cloudwatch"]
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/api/gateway_rest_api"
  }
}

action "terraform-validate-rest-api" {
  uses = "hashicorp/terraform-github-actions/validate@v0.3.4"
  needs = "terraform-init-rest-api"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/api/gateway_rest_api"
  }
}

action "terraform-plan-rest-api" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-validate-rest-api"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["-out", "plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/api/gateway_rest_api"
  }
}

action "terraform-apply-rest-api" {
  uses = "hashicorp/terraform-github-actions/apply@v0.3.4"
  needs = "terraform-plan-rest-api"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/api/gateway_rest_api"
  }
}

action "terraform-init-api-deployment" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.4"
  needs = ["terraform-apply-rest-api"]
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/api/gateway_deployment"
  }
}

action "terraform-validate-api-deployment" {
  uses = "hashicorp/terraform-github-actions/validate@v0.3.4"
  needs = "terraform-init-api-deployment"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "app/api/gateway_deployment"
  }
}

action "terraform-workspace-api-deployment" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-validate-api-deployment"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  runs = ["sh", "-c", "cd $TF_ACTION_WORKING_DIR; terraform workspace select $GITHUB_HEAD_REF || terraform workspace new $GITHUB_HEAD_REF"]
  env = {
    TF_ACTION_WORKING_DIR = "app/api/gateway_deployment"
  }
}

action "terraform-plan-api-deployment" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.4"
  needs = "terraform-workspace-api-deployment"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["-out", "plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/api/gateway_deployment"
  }
}

action "terraform-apply-api-deployment" {
  uses = "hashicorp/terraform-github-actions/apply@v0.3.4"
  needs = "terraform-plan-api-deployment"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  args = ["plan.tfplan"]
  env = {
    TF_ACTION_WORKING_DIR = "app/api/gateway_deployment"
  }
}