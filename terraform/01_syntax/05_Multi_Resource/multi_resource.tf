#Count
# All resources have a `count` meta-parameter.
# If count is set then a list of resources is returned (even if there is only 1)
# If `count` is set then a `count.index` value is available.  This value contains
# the current iteration number.
# TIP: setting `count = 0` is a handy way to remove a resource but keep the config.
resource "aws_s3_bucket" "count_buckets" {
  count  = 1
  # count = var.create_bucket == true ? 1 : 0
  bucket = "${data.aws_caller_identity.current.account_id}-bucket${count.index}"
}


#For Each
# All resources may have a `for_each` meta parameter.
# you can use for_each to iterate over any iterable item (list, set, map, or object).
# An empty iterator won't create any resource.
resource "aws_s3_bucket" "each_buckets" {
  for_each = toset(data.aws_availability_zones.available.names)

  bucket = "${data.aws_caller_identity.current.account_id}-${each.value}"
  tags = {
    description = each.value
  }
}
