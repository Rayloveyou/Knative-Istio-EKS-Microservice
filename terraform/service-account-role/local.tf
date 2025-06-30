data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  REGION     = data.aws_region.current.name
  ACCOUNT_ID = data.aws_caller_identity.current.account_id
}