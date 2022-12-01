
resource "aws_s3_bucket" "a_bucket" {
}

# Refactoring can achived with the moved block or with
# `terraform state mv`
#moved {
#  from = aws_s3_bucket.a_bucket
#  to   = aws_s3_bucket.moved_bucket
#}
