# Terraform HCL
data "null_data_source" "example" {
  inputs = null
}
# type = data
# label = null_data_source
# label = example
# { inputs = null } = body

# Expressions
# used to refer to or compute values within a configuration.

# Local Values
# allow you to assign a name to an expression.
# Locals can make your code more readable by eliminating duplicate code (DRY).
locals {
  a_local = "Terraform"
}
# There may be multiple locals blocks, but the namespace is global.

#Interpolation
# Substitute values in strings.
locals {
  another_local = "${local.a_local} is fun."
}

#Data types
# Terraform supports simple and complex data types
locals {
  a_string  = "This is a string."
  a_number  = 3.1415
  a_boolean = true
  a_list = [
    "element1",
    2,
    "three"
  ]
  a_map = {
    key = "value"
  }

  # Complex
  person = {
    name = "Robert Jordan",
    phone_numbers = {
      home   = "415-444-1212",
      mobile = "415-555-1313"
    },
    active = false,
    age    = 32
  }
}

#Operators
# Terraform supports arithmetic and logical operations in expressions too
locals {
  //Arithmetic
  three = 1 + 2 // addition
  two   = 3 - 1 // subtraction
  one   = 2 / 2 // division
  zero  = 1 * 0 // multiplication

  //Logical
  t = true || false // OR true if either value is true
  f = true && false // AND true if both values are true

  //Comparison
  gt  = 2 > 1  // true if right value is greater
  gte = 2 >= 1 // true if right value is greater or equal
  lt  = 1 < 2  // true if left value is greater
  lte = 1 <= 2 // true if left value is greate or equal
  eq  = 1 == 1 // true if left and right are equal
  neq = 1 != 2 // true if left and right are not equal
}

# References
locals {
  a_ref = data.null_data_source.example.random
}

#Conditionals
locals {
  is_null = data.null_data_source.example.random == null ? true : false
}

#Functions
# Terraform has 100+ built in functions (but no ability to define custom functions!)
# https://www.terraform.io/docs/configuration/functions.html
# The syntax for a function call is <function_name>(<arg1>, <arg2>).
locals {
  //Date and Time
  ts            = timestamp() //Returns the current date and time.
  current_month = formatdate("MMMM", local.ts)
  tomorrow      = formatdate("DD", timeadd(local.ts, "24h"))
}

locals {
  //String
  lcase          = lower("A mixed case String")
  ucase          = upper("a lower case string")
  trimmed        = trimspace(" A string with leading and trailing spaces    ")
  formatted      = format("Hello %s", "World")
  formatted_list = formatlist("Hello %s", ["John", "Paul", "George", "Ringo"])
}

#Iteration
# HCL has a `for` syntax for iterating over list values.
# 
locals {
  l          = ["one", "two", "three"]
  upper_list = [for item in local.l : upper(item)]
  upper_map  = { for item in local.l : item => upper(item) }
}

#Filtering
# The `for` syntax can also filter with the `if` clause.
locals {
  n     = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  evens = [for i in local.n : i if i % 2 == 0]
}

#Directives and Heredocs
# HCL supports more complex string templating that can be used to generate
# full descriptive paragraphs too.
locals {
  heredoc = <<-EOT
    This is called a `heredoc`.  It's a string literal
    that can span multiple lines.
  EOT
}

locals {
  template = <<-EOT
    This is a `heredoc` with directives.
    %{if local.person.name == ""}
    Sorry, I don't know your name.
    %{else}
    Hi ${local.person.name}
    %{endif}
  EOT
}
