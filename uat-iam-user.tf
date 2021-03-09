variable "uat_account_id" {
}

module "uat-iam-credentials" {
  source            = "./modules/iam-credentials"
  env               = "uat"
  target_account_id = var.uat_account_id
}
