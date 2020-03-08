module "kms" {
  source      = "JamesWoolfenden/kms/aws"
  version     = "0.0.3"
  common_tags = var.common_tags
  key         = var.key
  accounts    = var.accounts
}
