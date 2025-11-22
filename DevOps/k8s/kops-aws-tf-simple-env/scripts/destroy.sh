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

echo -e "${YELLOW}Starting cluster destruction...${NC}"

# Export kops state store
export KOPS_STATE_STORE="${KOPS_STATE_STORE}"

# Step 1: Delete kops cluster
echo -e "${YELLOW}Step 1: Deleting kops cluster...${NC}"
read -p "Are you sure you want to delete the cluster? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kops delete cluster --name="${CLUSTER_NAME}" --yes
fi

# Step 2: Destroy Terraform infrastructure
echo -e "${YELLOW}Step 2: Destroying Terraform infrastructure...${NC}"
cd "${TERRAFORM_DIR}"

read -p "Do you want to destroy Terraform infrastructure? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform destroy
fi

cd ..

echo -e "${GREEN}Destruction completed!${NC}"

