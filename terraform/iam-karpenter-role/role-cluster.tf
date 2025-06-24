locals {
  KarpenterControllerRole = templatefile("${path.module}/KarpenterControllerTrustPolicy.json", {
    OIDC_PROVIDER = replace(var.eks_oidc_provider, "https://", "")
    ACCOUNT_ID    = local.ACCOUNT_ID
    NAMESPACE     = var.namespace
  })
}

resource "aws_iam_role" "KarpenterControllerRole" {
  name = "${var.cluster_name}-KarpenterControllerRole"

  assume_role_policy = local.KarpenterControllerRole
#   lifecycle {
#     ignore_changes = [ assume_role_policy ]
#   }
}

locals {
  KarpenterControllerPolicy = templatefile("${path.module}/KarpenterControllerPolicy.json", {
    ACCOUNT_ID   = local.ACCOUNT_ID
    REGION       = local.REGION
    CLUSTER_NAME = var.cluster_name
  })
}
resource "aws_iam_policy" "KarpenterControllerPolicy" {
  name = "KarpenterControllerPolicy"

  policy = local.KarpenterControllerPolicy

}



resource "aws_iam_role_policy_attachment" "KarpenterController" {
  role       = aws_iam_role.KarpenterControllerRole.name
  policy_arn = aws_iam_policy.KarpenterControllerPolicy.arn
}