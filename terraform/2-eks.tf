

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name                             = local.cluster_name
  cluster_version                          = "1.32"
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns            = { most_recent = true }
    kube-proxy         = { most_recent = true }
    vpc-cni            = { most_recent = true }
    aws-ebs-csi-driver = { most_recent = true }
    metrics-server     = { most_recent = true }
    # aws-efs-csi-driver = {
    #   most_recent              = true
    #   service_account_role_arn = aws_iam_role.efs_csi_controller_irsa.arn
    # }
  }

  eks_managed_node_groups = {
    example = {
      instance_types = ["t3.medium"]
      min_size       = 0
      max_size       = 5
      desired_size   = 2

     //add role để thao tác với aws resource 
      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy               = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy                    = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEC2ContainerRegistryReadOnly      = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonEBSCSIDriverPolicy                = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemClientFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
      }
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  node_security_group_tags = {
    "karpenter.sh/discovery" = local.cluster_name
  }


}

module "karpenter_role" {
  source            = "./iam-karpenter-role"
  eks_oidc_provider = module.eks.oidc_provider
  cluster_name      = module.eks.cluster_name
  namespace         = "karpenter"
}

output "karpenter_role" {
  value = module.karpenter_role
}