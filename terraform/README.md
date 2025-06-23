# Terraform Infrastructure as Code

This directory contains the Terraform configurations to provision the complete infrastructure for the microservices project on AWS EKS using **Terraform AWS Modules**.

## 📋 Overview

The Terraform configuration creates a production-ready EKS cluster with:
- **VPC** with public and private subnets across multiple AZs using `terraform-aws-modules/vpc/aws`
- **EKS Cluster** with proper IAM roles and security groups using `terraform-aws-modules/eks/aws`
- **Node Groups** for running workloads with auto-scaling
- **NAT Gateway** for outbound internet access
- **Internet Gateway** for public access
- **EBS CSI Driver** for persistent storage
- **Karpenter-ready** configuration for advanced auto-scaling

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS Infrastructure                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│  │   Internet  │ │     NAT     │ │     EKS     │ │   Security  │ │
│  │  Gateway    │ │  Gateway    │ │   Cluster   │ │   Groups    │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│  │   Public    │ │   Private   │ │   Route     │ │   IAM       │ │
│  │  Subnets    │ │  Subnets    │ │   Tables    │ │   Roles     │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Files

- `0-providers.tf` - AWS provider configuration and Terraform settings
- `1-vpc.tf` - VPC, subnets, and networking configuration
- `2-eks.tf` - EKS cluster and node groups configuration
- `README.md` - This documentation file

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** (>= 1.0) installed
3. **kubectl** (>= 1.24) installed
4. **AWS Account** with EKS permissions

### Required AWS Permissions

Your AWS user/role needs the following permissions:
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`
- `AmazonEKSVPCResourceController`
- `AmazonEBSCSIDriverPolicy`
- `AmazonElasticFileSystemClientFullAccess`

### Deployment

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Deploy infrastructure
terraform apply

# Configure kubectl for the new cluster
aws eks update-kubeconfig --region us-east-1 --name datnghiem-eks

# Verify cluster access
kubectl cluster-info
```

### Destroy Infrastructure

```bash
# Destroy all resources
terraform destroy
```

## 🔧 Configuration

### Current Configuration

The infrastructure is configured with the following settings:

#### VPC Configuration (`1-vpc.tf`)
- **Region**: `us-east-1`
- **VPC CIDR**: `10.0.0.0/16`
- **Availability Zones**: `us-east-1a`, `us-east-1b`
- **Public Subnets**: `10.0.1.0/24`, `10.0.2.0/24`
- **Private Subnets**: `10.0.3.0/24`, `10.0.4.0/24`
- **NAT Gateway**: Single NAT Gateway (cost-optimized)
- **Tags**: Properly tagged for EKS and Karpenter integration

#### EKS Configuration (`2-eks.tf`)
- **Cluster Name**: `datnghiem-eks`
- **Kubernetes Version**: `1.32`
- **Node Group**: `t3.medium` instances
- **Scaling**: 2-5 nodes (auto-scaling)
- **Add-ons**: CoreDNS, kube-proxy, VPC CNI, EBS CSI Driver, Metrics Server
- **IAM Policies**: All necessary worker node policies

### Customization

To customize the configuration, modify the `locals` block in `1-vpc.tf`:

```hcl
locals {
  account_id           = "YOUR_ACCOUNT_ID"
  region               = "us-east-1"
  cluster_name         = "your-cluster-name"
  cidr                 = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}
```

## 🏗️ Resource Details

### VPC Configuration

- **CIDR Block**: `10.0.0.0/16`
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled
- **Tags**: Properly tagged for EKS and Karpenter integration

### Subnet Configuration

#### Public Subnets
- **Purpose**: Load balancers and bastion hosts
- **Auto-assign Public IP**: Enabled
- **Route Table**: Routes to Internet Gateway
- **Tags**: `kubernetes.io/role/elb: "1"`

#### Private Subnets
- **Purpose**: EKS worker nodes and application pods
- **Auto-assign Public IP**: Disabled
- **Route Table**: Routes to NAT Gateway
- **Tags**: 
  - `kubernetes.io/role/internal-elb: "1"`
  - `karpenter.sh/discovery: datnghiem-eks`
  - `kubernetes.io/cluster/datnghiem-eks: "owned"`

### EKS Cluster

- **Version**: Kubernetes 1.32
- **Endpoint Access**: Public access enabled
- **Security Groups**: Minimal required access
- **IAM Roles**: Properly configured for EKS
- **Creator Admin Permissions**: Enabled

### Node Groups

- **Instance Types**: t3.medium
- **Scaling**: 2-5 nodes (auto-scaling)
- **Subnets**: Private subnets only
- **IAM Roles**: All necessary worker node policies attached
- **Security Groups**: Tagged for Karpenter discovery

### Cluster Add-ons

- **CoreDNS**: DNS resolution
- **kube-proxy**: Network proxy
- **VPC CNI**: AWS VPC networking
- **EBS CSI Driver**: Persistent storage
- **Metrics Server**: Resource metrics

## 📊 Outputs

After successful deployment, the EKS module provides these outputs:

| Output | Description |
|--------|-------------|
| `cluster_endpoint` | EKS cluster API endpoint |
| `cluster_security_group_id` | Security group ID |
| `cluster_iam_role_name` | IAM role name |
| `cluster_certificate_authority_data` | CA certificate data |
| `vpc_id` | VPC ID |
| `public_subnets` | List of public subnet IDs |
| `private_subnets` | List of private subnet IDs |
| `cluster_name` | EKS cluster name |
| `cluster_oidc_issuer_url` | OIDC issuer URL |

### Using Outputs

```bash
# Get cluster endpoint
terraform output cluster_endpoint

# Get VPC ID
terraform output vpc_id

# Get all outputs
terraform output
```

## 🔐 Security

### Network Security

- **Private Subnets**: Worker nodes run in private subnets
- **Security Groups**: Minimal required access
- **NAT Gateway**: Outbound internet access through NAT
- **No Direct Internet**: Worker nodes cannot be accessed directly

### IAM Security

- **Least Privilege**: Minimal required permissions
- **Service Accounts**: Proper IAM roles for EKS
- **Node IAM**: Worker nodes have all necessary policies:
  - `AmazonEKSWorkerNodePolicy`
  - `AmazonEKS_CNI_Policy`
  - `AmazonEC2ContainerRegistryReadOnly`
  - `AmazonEBSCSIDriverPolicy`
  - `AmazonElasticFileSystemClientFullAccess`

### Encryption

- **EBS Encryption**: All EBS volumes are encrypted
- **TLS**: EKS API endpoint uses TLS
- **Secrets**: Kubernetes secrets should be encrypted

## 💰 Cost Optimization

### Current Configuration

- **NAT Gateway**: Single NAT Gateway (cost-optimized)
- **Instance Types**: t3.medium (good balance)
- **Node Count**: 2-5 nodes (auto-scaling)

### Cost Reduction Options

```hcl
# Use smaller instance types
instance_types = ["t3.small"]

# Reduce node count
min_size = 1
max_size = 3
desired_size = 1
```

### Production Considerations

```hcl
# High availability configuration
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
min_size = 3
max_size = 10
instance_types = ["t3.large", "t3.xlarge"]

# Spot instances for cost savings
capacity_type = "SPOT"
```

## 🔍 Monitoring and Troubleshooting

### Check Infrastructure Status

```bash
# Check Terraform state
terraform show

# Check specific resources
terraform state list
terraform state show module.eks

# Validate configuration
terraform validate
terraform plan
```

### Common Issues

#### 1. VPC Limits

```bash
# Check VPC limits
aws ec2 describe-account-attributes --attribute-names max-vpcs

# If limit exceeded, delete unused VPCs
aws ec2 describe-vpcs --query 'Vpcs[?State==`available`].[VpcId,Tags[?Key==`Name`].Value]' --output table
```

#### 2. Subnet CIDR Conflicts

```bash
# Check existing VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock]' --output table

# Modify cidr in locals if conflicts exist
```

#### 3. IAM Role Issues

```bash
# Check IAM roles
aws iam list-roles --query 'Roles[?contains(RoleName, `datnghiem-eks`)].RoleName'

# Check role policies
aws iam list-attached-role-policies --role-name <role-name>
```

## 🚀 Next Steps

After infrastructure deployment:

1. **Deploy ALB Controller**:
   ```bash
   cd ../stateful/resources
   ./setup-alb-controller.sh
   ```

2. **Deploy Applications**:
   ```bash
   # Traditional deployment
   cd .. && ./deploy_stateful.sh
   
   # Or Knative deployment
   cd ../knative && ./deploy_knative.sh
   ```

3. **Configure DNS**:
   - Point domains to Load Balancer DNS
   - Configure SSL certificates

4. **Set up Monitoring**:
   - Deploy Prometheus and Grafana
   - Configure logging (ELK stack)

## 📚 Additional Resources

- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform AWS VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Terraform AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Karpenter Documentation](https://karpenter.sh/)

## 🔄 Updates and Maintenance

### Updating Kubernetes Version

```bash
# Update cluster_version in 2-eks.tf
# Then run:
terraform plan
terraform apply
```

### Adding Node Groups

```bash
# Add new node group configuration to eks_managed_node_groups in 2-eks.tf
# Then run:
terraform plan
terraform apply
```

### Scaling Infrastructure

```bash
# Update node group sizes
terraform apply -var="min_size=5" -var="max_size=10"
```

## 🧹 Cleanup

### Complete Cleanup

```bash
# Destroy all infrastructure
terraform destroy

# Remove Terraform state
rm -rf .terraform*
```

### Partial Cleanup

```bash
# Remove specific resources
terraform destroy -target=module.eks
terraform destroy -target=module.vpc
```

## 📞 Support

For issues and questions:
1. Check AWS EKS documentation
2. Review Terraform provider documentation
3. Check AWS CloudTrail for API errors
4. Verify IAM permissions and policies 