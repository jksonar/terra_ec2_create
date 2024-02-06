variable "first_var" {
  default = "string variables"
  type = string
}

output "print_variable" {
  value = var.first_var
}