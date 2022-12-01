# Modules
Modules are collections of Terraform resources grouped together by function. Modules can be thought of as customized resources, but they don't behave exactly as resources do.

## When to use modules

> 🚧 Warning: Opinion
>> almost all Terraform code should be contained in modules.  Root configs should consist almost entirely of module calls.

```
We do not recommend writing modules that are just thin wrappers around single other resource types. If you have trouble finding a name for your module that isn't the same as the main resource type inside it, that may be a sign that your module is not creating any new abstraction and so the module is adding unnecessary complexity. Just use the resource type directly in the calling module instead.
                      - Hashicorp
```

```
Large modules considered harmful.
                      - Yevgeniy Brikman(Gruntwork)
```

Counter argument:

Thin wrappers around resources have a few advantages (CDK uses L1 & L2 Constructs to describe these):
1. A module may be created to wrap a low level resource in order to provide compliant defaults.  Users of the module can be confident that if they don't know what a setting does it will do the right thing by default.
2. Sometimes the name rule just doesn't apply... Functioning EKS Clusters, VPCs, even S3 Buckets are much more complex than their provider resources.
3. Layering modules(composition) can ease maintenance.