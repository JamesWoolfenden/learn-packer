variable "common_tags" {
  description = "This is to help you add tags to your cloud objects"
  type        = map
}

variable "key" {
}

variable "accounts" {
  type = list
}

variable "alias" {
  type=string
}
