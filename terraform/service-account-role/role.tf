

locals {
  Role = templatefile("${path.module}/TrustPolicy.json", {
    OIDC_PROVIDER = replace(var.eks_oidc_provider, "https://", "")
    ACCOUNT_ID      = local.ACCOUNT_ID
    NAMESPACE       = var.namespace
    SERVICE_ACCOUNT = var.service_account_name
  })
}

resource "aws_iam_role" "Role" {
  name = "${var.service_account_name}-Role"

  assume_role_policy = local.Role
}

locals {
  Policy = templatefile(var.policy_file_path , {
    
  })
}


resource "aws_iam_policy" "Policy" {
  name = "${var.service_account_name}-Policy"

  policy = local.Policy

}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.Role.name
  policy_arn = aws_iam_policy.Policy.arn
}