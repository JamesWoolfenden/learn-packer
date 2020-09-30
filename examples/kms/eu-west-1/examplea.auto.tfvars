common_tags = {
"createdby" = "Terraform" }

accounts = ["680235478471","216849691610"]
key = {
  description              = "AMI-Shared"
  deletion_window_in_days  = 30
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled               = true
}

alias="alias/ami-shared"
