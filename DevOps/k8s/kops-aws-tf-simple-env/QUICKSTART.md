# Quick Start Guide

## Prerequisites Checklist

- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] Terraform >= 1.0 installed
- [ ] kops >= 1.28.0 installed
- [ ] kubectl >= 1.28.0 installed
- [ ] jq installed (`brew install jq` on macOS)
- [ ] S3 bucket created for kops state
- [ ] S3 bucket created for Terraform state (optional but recommended)

## Step-by-Step Deployment

### 1. Create S3 Buckets

```bash
# For kops state
aws s3 mb s3://your-kops-state-bucket
aws s3api put-bucket-versioning \
  --bucket your-kops-state-bucket \
  --versioning-configuration Status=Enabled

# For Terraform state (optional)
aws s3 mb s3://your-terraform-state-bucket
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled
```

### 2. Configure Terraform

```bash
cd terraform

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Configure S3 backend in main.tf (uncomment and update)
# backend "s3" {
#   bucket = "your-terraform-state-bucket"
#   key    = "kops-simple-env/terraform.tfstate"
#   region = "ap-southeast-1"
# }
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply
terraform apply
```

### 4. Configure kops

```bash
# Set kops state store
export KOPS_STATE_STORE="s3://your-kops-state-bucket"

# Update deploy.sh with your bucket name
# Edit scripts/deploy.sh and set KOPS_STATE_STORE
```

### 5. Create kops Cluster

```bash
# Get Terraform outputs
cd terraform
VPC_ID=$(terraform output -raw vpc_id)
PRIVATE_SUBNETS=$(terraform output -json private_subnet_ids | jq -r '.[]' | tr '\n' ',' | sed 's/,$//')
CONTROL_PLANE_PROFILE=$(terraform output -raw control_plane_iam_instance_profile)
WORKER_PROFILE=$(terraform output -raw worker_node_iam_instance_profile)
CONTROL_PLANE_SG=$(terraform output -raw control_plane_security_group_id)
WORKER_SG=$(terraform output -raw worker_node_security_group_id)
KMS_KEY_ID=$(terraform output -raw kms_key_id 2>/dev/null || echo "")
cd ..

# Create cluster
kops create -f cluster.yaml

# Create instance groups
kops create -f control-plane.yaml
kops create -f nodes.yaml

# Update instance groups with Terraform outputs
kops edit instancegroup control-plane
# Add:
#   iam:
#     profile: <CONTROL_PLANE_PROFILE>
#   additionalSecurityGroups:
#     - <CONTROL_PLANE_SG>
#   rootVolumeKmsKeyId: <KMS_KEY_ID>  # if encryption enabled

kops edit instancegroup nodes
# Add:
#   iam:
#     profile: <WORKER_PROFILE>
#   additionalSecurityGroups:
#     - <WORKER_SG>
#   rootVolumeKmsKeyId: <KMS_KEY_ID>  # if encryption enabled

# Update and create cluster
kops update cluster --name kops-simple-cluster.k8s.local --yes

# Wait for cluster to be ready
kops validate cluster --name kops-simple-cluster.k8s.local --wait 10m
```

### 6. Deploy Addons

```bash
# Get IAM role ARN
cd terraform
WORKER_ROLE_ARN=$(terraform output -raw worker_node_iam_role_arn)
KMS_KEY_ID=$(terraform output -raw kms_key_id 2>/dev/null || echo "")
cd ..

# Deploy AWS VPC CNI
sed "s|<WORKER_NODE_IAM_ROLE_ARN>|${WORKER_ROLE_ARN}|g" addons/aws-vpc-cni.yaml | kubectl apply -f -

# Deploy EBS CSI Driver
sed "s|<WORKER_NODE_IAM_ROLE_ARN>|${WORKER_ROLE_ARN}|g" addons/ebs-csi-driver.yaml | \
  sed "s|<KMS_KEY_ID>|${KMS_KEY_ID}|g" | kubectl apply -f -
```

### 7. Verify

```bash
# Check cluster
kubectl get nodes
kubectl get pods --all-namespaces

# Test storage
kubectl get storageclass

# Test networking
kubectl run test-pod --image=nginx --restart=Never
kubectl get pod test-pod -o wide
kubectl delete pod test-pod
```

## Common Commands

```bash
# Get cluster info
kops get cluster

# Edit cluster
kops edit cluster --name kops-simple-cluster.k8s.local

# Update cluster
kops update cluster --name kops-simple-cluster.k8s.local --yes

# Validate cluster
kops validate cluster --name kops-simple-cluster.k8s.local

# Get kubeconfig
kops export kubeconfig --name kops-simple-cluster.k8s.local

# Delete cluster
kops delete cluster --name kops-simple-cluster.k8s.local --yes
```

## Troubleshooting

### Cluster not ready
```bash
kops validate cluster --name kops-simple-cluster.k8s.local
kops get cluster kops-simple-cluster.k8s.local
kubectl get nodes
```

### Check logs
```bash
# Control plane logs
kubectl logs -n kube-system -l component=kube-apiserver

# CNI logs
kubectl logs -n kube-system -l k8s-app=aws-node

# CSI logs
kubectl logs -n kube-system -l app=ebs-csi-controller
```

### IAM issues
```bash
# Check instance profiles
aws iam get-instance-profile --instance-profile-name kops-simple-env-control-plane-profile
aws iam get-instance-profile --instance-profile-name kops-simple-env-worker-node-profile

# Check roles
aws iam get-role --role-name kops-simple-env-control-plane-role
aws iam get-role --role-name kops-simple-env-worker-node-role
```

## Next Steps

1. Configure monitoring (Prometheus, Grafana)
2. Set up logging (Fluentd, CloudWatch)
3. Configure ingress controller (NGINX, Traefik)
4. Set up CI/CD pipeline
5. Configure backup for etcd
6. Set up cluster autoscaling
7. Configure pod security policies
8. Set up network policies

