variable "common_tags" {
  description = "This is to help you add tags to your cloud objects"
  type        = map(any)
}

variable "key" {
}

variable "accounts" {
  type = list(any)
}

variable "alias" {
  type = string
}
