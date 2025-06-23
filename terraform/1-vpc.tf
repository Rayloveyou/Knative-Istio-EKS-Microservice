locals {
  account_id           = "115228050885"
  region               = "us-east-1"
  cluster_name         = "datnghiem-eks"
  cidr                 = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"
  name   = local.cluster_name
  cidr   = local.cidr

  azs             = local.availability_zones
  private_subnets = local.private_subnet_cidrs
  public_subnets  = local.public_subnet_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # ✅ Tag cho private subnet – nơi Karpenter sẽ launch EC2
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = 1
    "karpenter.sh/discovery"                      = local.cluster_name
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

}
