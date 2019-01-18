variable "project_name" {
  description = "Name of the project (to be used for prefixing services / configuration)"
}

variable "table_name" {
  description = "Name of the dynamodb table"
}

variable "billing_mode" {
  description = "Billing mode"
  default = "PROVISIONED"
}

variable "read_capacity_units" {
  description = "Dynamodb's read capacity"
  default = 5
}

variable "write_capacity_units" {
  description = "Dynamodb's write capacity"
  default = 5
}

variable "key_element_name" {
  description = "Primary Key Name"
}

variable "key_element_type" {
  description = "Primary Key Type"
}

####################
# Tags
####################

variable "tag_environment" {
  description = "Environment tag name (dev / test / prod)"
}
