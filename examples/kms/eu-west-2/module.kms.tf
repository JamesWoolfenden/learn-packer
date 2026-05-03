module "kms" {
  source = "git::https://github.com/JamesWoolfenden/terraform-aws-kms.git?ref=5e86ff865ce2139fb4af32686f541c234bd12b98" #v0.0.51
  common_tags = var.common_tags
  key         = var.key
  accounts    = var.accounts
  alias       = var.alias
}
