#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="kops-simple-cluster.k8s.local"
TERRAFORM_DIR="terraform"
KOPS_STATE_STORE="s3://your-kops-state-bucket"  # Update this with your S3 bucket

echo -e "${GREEN}Starting Kubernetes cluster deployment with kops and Terraform${NC}"

# Step 1: Deploy infrastructure with Terraform
echo -e "${YELLOW}Step 1: Deploying infrastructure with Terraform...${NC}"
cd "${TERRAFORM_DIR}"

# Initialize Terraform
terraform init

# Plan Terraform deployment
terraform plan -out=tfplan

# Apply Terraform
read -p "Do you want to apply Terraform changes? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply tfplan
    rm tfplan
fi

# Get outputs
VPC_ID=$(terraform output -raw vpc_id)
PRIVATE_SUBNET_IDS=$(terraform output -json private_subnet_ids | jq -r '.[]' | tr '\n' ',' | sed 's/,$//')
CONTROL_PLANE_PROFILE=$(terraform output -raw control_plane_iam_instance_profile)
WORKER_NODE_PROFILE=$(terraform output -raw worker_node_iam_instance_profile)
CONTROL_PLANE_SG=$(terraform output -raw control_plane_security_group_id)
WORKER_NODE_SG=$(terraform output -raw worker_node_security_group_id)
KMS_KEY_ID=$(terraform output -raw kms_key_id 2>/dev/null || echo "")

cd ..

# Step 2: Create kops cluster configuration
echo -e "${YELLOW}Step 2: Creating kops cluster configuration...${NC}"

# Export kops state store
export KOPS_STATE_STORE="${KOPS_STATE_STORE}"

# Create cluster configuration
kops create cluster \
    --name="${CLUSTER_NAME}" \
    --cloud=aws \
    --zones=ap-southeast-1a,ap-southeast-1b \
    --network-cidr=10.0.0.0/16 \
    --vpc="${VPC_ID}" \
    --subnets="${PRIVATE_SUBNET_IDS}" \
    --master-size=t3.medium \
    --node-size=t3.medium \
    --node-count=2 \
    --kubernetes-version=1.28.0 \
    --networking=amazonvpc \
    --yes

# Step 3: Update cluster configuration with Terraform outputs
echo -e "${YELLOW}Step 3: Updating cluster configuration with Terraform outputs...${NC}"

# Update control plane instance group
kops edit instancegroup control-plane
# Manually update:
# - iam.profile: ${CONTROL_PLANE_PROFILE}
# - additionalSecurityGroups: [${CONTROL_PLANE_SG}]
# - rootVolumeKmsKeyId: ${KMS_KEY_ID} (if encryption enabled)

# Update nodes instance group
kops edit instancegroup nodes
# Manually update:
# - iam.profile: ${WORKER_NODE_PROFILE}
# - additionalSecurityGroups: [${WORKER_NODE_SG}]
# - rootVolumeKmsKeyId: ${KMS_KEY_ID} (if encryption enabled)

# Step 4: Update cluster configuration
echo -e "${YELLOW}Step 4: Updating cluster configuration...${NC}"
kops update cluster --name="${CLUSTER_NAME}" --yes

# Step 5: Wait for cluster to be ready
echo -e "${YELLOW}Step 5: Waiting for cluster to be ready...${NC}"
kops validate cluster --name="${CLUSTER_NAME}" --wait 10m

# Step 6: Deploy addons
echo -e "${YELLOW}Step 6: Deploying addons...${NC}"

# Update addon manifests with IAM role ARNs
WORKER_NODE_ROLE_ARN=$(cd terraform && terraform output -raw worker_node_iam_role_arn && cd ..)

# Deploy AWS VPC CNI
sed "s|<WORKER_NODE_IAM_ROLE_ARN>|${WORKER_NODE_ROLE_ARN}|g" addons/aws-vpc-cni.yaml | kubectl apply -f -

# Deploy EBS CSI Driver
sed "s|<WORKER_NODE_IAM_ROLE_ARN>|${WORKER_NODE_ROLE_ARN}|g" addons/ebs-csi-driver.yaml | \
    sed "s|<KMS_KEY_ID>|${KMS_KEY_ID}|g" | kubectl apply -f -

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}Cluster name: ${CLUSTER_NAME}${NC}"
echo -e "${GREEN}To access the cluster, run: kubectl get nodes${NC}"

