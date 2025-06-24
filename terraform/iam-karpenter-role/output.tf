output "karpenter_controller_role_arn" {
    value = aws_iam_role.KarpenterControllerRole.arn


}

output "karpenter_node_role_arn" {
    value = aws_iam_role.KarpenterNodeRole.arn
}