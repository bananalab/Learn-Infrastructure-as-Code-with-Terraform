#!/usr/bin/env python

from constructs import Construct
from cdktf import App, TerraformStack
from cdktf_cdktf_provider_docker import Image, Container, DockerProvider


class MyStack(TerraformStack):
    def __init__(self, scope: Construct, ns: str):
        super().__init__(scope, ns)

        DockerProvider(self, 'docker')

        docker_image = Image(self, 'nginxImage',
            name='nginx:latest',
            keep_locally=False)

        Container(self, 'nginxContainer',
            name='tutorial',
            image=docker_image.name,
            ports=[{
                'internal': 80,
                'external': 8000
            }])


app = App()
MyStack(app, "learn-cdktf-docker")

app.synth()
