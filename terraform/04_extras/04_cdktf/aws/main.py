from constructs import Construct
from cdktf import App, TerraformStack
from imports.aws import AwsProvider
from imports.aws.sns import SnsTopic
from imports.terraform_aws_modules.aws import Vpc


class MyStack(TerraformStack):
    def __init__(self, scope: Construct, ns: str):
        super().__init__(scope, ns)

        AwsProvider(self, 'Aws', region='us-east-1')

        Vpc(self, 'CustomVpc',
            name='custom-vpc',
            cidr='10.0.0.0/16',
            azs=["us-east-1a", "us-east-1b"],
            public_subnets=["10.0.1.0/24", "10.0.2.0/24"]
            )
        SnsTopic(self, 'Topic', display_name='my-first-sns-topic')

app = App()
MyStack(app, "python-aws")

app.synth()
