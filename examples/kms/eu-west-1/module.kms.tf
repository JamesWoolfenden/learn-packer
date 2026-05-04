module "kms" {
  source = "git::https://github.com/JamesWoolfenden/terraform-aws-kms.git?ref=8ab76d4ee2dcd8aedbfb8ade041aa55572f34f57" #v0.0.53
  common_tags = var.common_tags
  key         = var.key
  accounts    = var.accounts
  alias       = var.alias
}
