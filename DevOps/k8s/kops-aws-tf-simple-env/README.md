# kops Simple Environment - Kubernetes Cluster

This project creates a production-ready Kubernetes cluster using kops and Terraform on AWS with best practices for networking, IAM, CSI, and security.

## Architecture

- **1 Control Plane Node**: t3.medium instance in ap-southeast-1a
- **1-2 Worker Nodes**: t3.medium instances across ap-southeast-1a and ap-southeast-1b
- **VPC**: 10.0.0.0/16 with public and private subnets
- **Networking**: AWS VPC CNI for pod networking
- **Storage**: EBS CSI Driver for persistent volumes
- **Security**: Encryption at rest, IAM roles, security groups, KMS keys

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0
3. **kops** >= 1.28.0
4. **kubectl** >= 1.28.0
5. **jq** for JSON processing
6. **S3 Bucket** for kops state storage
7. **Route53 Hosted Zone** (optional, using k8s.local for local DNS)

## Project Structure

```
kops-simple-env/
├── terraform/              # Terraform infrastructure code
│   ├── main.tf            # Provider and backend configuration
│   ├── variables.tf       # Variable definitions
│   ├── vpc.tf             # VPC, subnets, NAT gateways
│   ├── iam.tf             # IAM roles and policies
│   ├── security.tf        # Security groups and KMS keys
│   ├── outputs.tf         # Terraform outputs
│   └── terraform.tfvars.example
├── cluster.yaml           # kops cluster configuration
├── control-plane.yaml     # Control plane instance group
├── nodes.yaml             # Worker node instance group
├── addons/                # Kubernetes addons
│   ├── aws-vpc-cni.yaml   # AWS VPC CNI configuration
│   └── ebs-csi-driver.yaml # EBS CSI Driver configuration
├── secrets/               # Secret examples
│   ├── aws-secret.yaml.example
│   └── kubernetes-secrets.yaml.example
├── scripts/               # Deployment scripts
│   ├── deploy.sh          # Deployment script
│   └── destroy.sh         # Destruction script
└── README.md
```

## Features

### Networking (CNI)
- **AWS VPC CNI**: Native AWS networking for pods
- **VPC**: Isolated network with public and private subnets
- **NAT Gateways**: Internet access for private subnets
- **Security Groups**: Network-level security controls

### Storage (CSI)
- **EBS CSI Driver**: Dynamic provisioning of EBS volumes
- **Encryption**: EBS volumes encrypted with KMS
- **Storage Classes**: Pre-configured gp3 storage class

### IAM
- **Control Plane Role**: Minimal permissions for control plane
- **Worker Node Role**: Permissions for EBS CSI, VPC CNI, ECR
- **Instance Profiles**: Attached to EC2 instances

### Security
- **Encryption at Rest**: EBS volumes encrypted with KMS
- **Encryption in Transit**: TLS for etcd and API server
- **Security Groups**: Restrictive firewall rules
- **IAM Policies**: Least privilege access
- **SSH Hardening**: Disabled password authentication
- **Audit Logging**: Enabled on nodes

## Quick Start

### 1. Configure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

Update `terraform/main.tf` with your S3 backend configuration:

```hcl
backend "s3" {
  bucket = "your-terraform-state-bucket"
  key    = "kops-simple-env/terraform.tfstate"
  region = "ap-southeast-1"
}
```

### 2. Configure kops State Store

Create an S3 bucket for kops state:

```bash
aws s3 mb s3://your-kops-state-bucket
aws s3api put-bucket-versioning \
  --bucket your-kops-state-bucket \
  --versioning-configuration Status=Enabled
```

Update `scripts/deploy.sh` with your bucket name:

```bash
KOPS_STATE_STORE="s3://your-kops-state-bucket"
```

### 3. Deploy Infrastructure

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy everything
./scripts/deploy.sh
```

Or deploy manually:

#### Step 1: Deploy Terraform Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

#### Step 2: Get Terraform Outputs

```bash
terraform output
```

#### Step 3: Create kops Cluster

```bash
export KOPS_STATE_STORE="s3://your-kops-state-bucket"

# Create cluster
kops create -f cluster.yaml

# Create instance groups
kops create -f control-plane.yaml
kops create -f nodes.yaml

# Update cluster with Terraform outputs
# Edit the instance groups to add:
# - IAM instance profiles
# - Security groups
# - KMS key IDs

kops update cluster --name kops-simple-cluster.k8s.local --yes
kops validate cluster --name kops-simple-cluster.k8s.local --wait 10m
```

#### Step 4: Deploy Addons

```bash
# Get IAM role ARN from Terraform
WORKER_ROLE_ARN=$(cd terraform && terraform output -raw worker_node_iam_role_arn)

# Deploy AWS VPC CNI
sed "s|<WORKER_NODE_IAM_ROLE_ARN>|${WORKER_ROLE_ARN}|g" addons/aws-vpc-cni.yaml | kubectl apply -f -

# Deploy EBS CSI Driver
KMS_KEY_ID=$(cd terraform && terraform output -raw kms_key_id)
sed "s|<WORKER_NODE_IAM_ROLE_ARN>|${WORKER_ROLE_ARN}|g" addons/ebs-csi-driver.yaml | \
  sed "s|<KMS_KEY_ID>|${KMS_KEY_ID}|g" | kubectl apply -f -
```

### 4. Verify Deployment

```bash
# Check nodes
kubectl get nodes

# Check pods
kubectl get pods --all-namespaces

# Check storage classes
kubectl get storageclass

# Check CNI
kubectl get daemonset -n kube-system aws-node

# Check CSI
kubectl get deployment -n kube-system ebs-csi-controller
```

## Configuration

### Variables

Key variables in `terraform/variables.tf`:

- `aws_region`: AWS region (default: ap-southeast-1)
- `vpc_cidr`: VPC CIDR block (default: 10.0.0.0/16)
- `kubernetes_version`: Kubernetes version (default: 1.28.0)
- `node_count`: Number of worker nodes (default: 2)
- `enable_encryption`: Enable EBS encryption (default: true)

### Cluster Configuration

Edit `cluster.yaml` to customize:
- Kubernetes version
- Network CIDR
- Subnet configuration
- API server settings
- etcd configuration

### Instance Groups

- `control-plane.yaml`: Control plane configuration
- `nodes.yaml`: Worker node configuration

## Security Best Practices

1. **Encryption**: All EBS volumes encrypted with KMS
2. **Network Security**: Security groups restrict traffic
3. **IAM**: Least privilege IAM policies
4. **Secrets**: Use AWS Secrets Manager or External Secrets Operator
5. **SSH**: Password authentication disabled
6. **Audit**: Audit logging enabled
7. **TLS**: etcd and API server use TLS

## Secrets Management

### Option 1: AWS Secrets Manager (Recommended)

Use External Secrets Operator:

```bash
kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/charts/external-secrets/templates/crds/bundle.yaml
```

### Option 2: Kubernetes Secrets

See examples in `secrets/` directory. **Never commit actual secrets to git!**

## Monitoring and Logging

Consider adding:
- **Prometheus** for metrics
- **Grafana** for visualization
- **CloudWatch Container Insights** for AWS-native monitoring
- **Fluentd/Fluent Bit** for log aggregation

## Troubleshooting

### Cluster not ready

```bash
kops validate cluster --name kops-simple-cluster.k8s.local
kops get cluster kops-simple-cluster.k8s.local
```

### Pod networking issues

```bash
kubectl logs -n kube-system -l k8s-app=aws-node
```

### Storage issues

```bash
kubectl logs -n kube-system -l app=ebs-csi-controller
kubectl get pv
kubectl get pvc
```

### IAM issues

Check IAM roles and policies:
```bash
aws iam get-role --role-name kops-simple-env-worker-node-role
aws iam list-role-policies --role-name kops-simple-env-worker-node-role
```

## Cleanup

```bash
./scripts/destroy.sh
```

Or manually:

```bash
# Delete kops cluster
kops delete cluster --name kops-simple-cluster.k8s.local --yes

# Destroy Terraform
cd terraform
terraform destroy
```

## Cost Optimization

- Use **t3.small** for development (update in variables)
- Use **Spot Instances** for worker nodes (add to nodes.yaml)
- Use **NAT Instance** instead of NAT Gateway for dev (not recommended for prod)
- Enable **Cluster Autoscaler** to scale nodes based on demand

## Additional Resources

- [kops Documentation](https://kops.sigs.k8s.io/)
- [AWS VPC CNI](https://github.com/aws/amazon-vpc-cni-k8s)
- [EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)

## License

This project is provided as-is for educational and development purposes.

