variable "rules" {
  type = list(object({
    port        = number
    description = string
    cidr        = string
  }))
  /*default = [{
    port        = 443
    description = "Ingress for HTTPS"
    cidr        = "0.0.0.0/0"
    },
    {
      port        = 80
      description = "Ingress for HTTP"
      cidr        = "0.0.0.0/0"
  }]*/
}
