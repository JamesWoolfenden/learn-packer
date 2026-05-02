module "kms" {
  source = "git::https://github.com/JamesWoolfenden/terraform-aws-kms.git?ref=37b7448bc1bf47c0e4fa5e7be241583801195eea" #v0.0.3
  common_tags = var.common_tags
  key         = var.key
  accounts    = var.accounts
  alias       = var.alias
}
