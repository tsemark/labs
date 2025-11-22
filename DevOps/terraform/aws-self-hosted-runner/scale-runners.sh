#!/bin/bash
# Helper script to manually scale GitHub runners

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if terraform is available
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed or not in PATH"
    exit 1
fi

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed or not in PATH"
    exit 1
fi

# Get ASG name from Terraform output
print_info "Getting Auto Scaling Group name from Terraform..."
ASG_NAME=$(terraform output -raw dynamic_runners_autoscaling_group_name 2>/dev/null || echo "")

if [ -z "$ASG_NAME" ]; then
    print_error "Could not get ASG name from Terraform. Make sure you've run 'terraform apply' first."
    exit 1
fi

print_info "Found ASG: $ASG_NAME"

# Get current capacity
print_info "Getting current capacity..."
CURRENT_CAPACITY=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --query 'AutoScalingGroups[0].DesiredCapacity' \
    --output text)

print_info "Current desired capacity: $CURRENT_CAPACITY"

# Get min and max
MIN_SIZE=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --query 'AutoScalingGroups[0].MinSize' \
    --output text)

MAX_SIZE=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --query 'AutoScalingGroups[0].MaxSize' \
    --output text)

print_info "Min size: $MIN_SIZE, Max size: $MAX_SIZE"

# Check if capacity is provided as argument
if [ -z "$1" ]; then
    echo ""
    print_warn "Usage: $0 <desired-capacity>"
    echo ""
    echo "Example: $0 5  (scale to 5 runners)"
    echo ""
    echo "Current capacity: $CURRENT_CAPACITY"
    echo "Valid range: $MIN_SIZE - $MAX_SIZE"
    exit 1
fi

DESIRED_CAPACITY=$1

# Validate capacity
if ! [[ "$DESIRED_CAPACITY" =~ ^[0-9]+$ ]]; then
    print_error "Desired capacity must be a number"
    exit 1
fi

if [ "$DESIRED_CAPACITY" -lt "$MIN_SIZE" ] || [ "$DESIRED_CAPACITY" -gt "$MAX_SIZE" ]; then
    print_error "Desired capacity ($DESIRED_CAPACITY) is outside valid range ($MIN_SIZE - $MAX_SIZE)"
    exit 1
fi

# Confirm action
echo ""
print_warn "You are about to scale the dynamic runners ASG:"
echo "  ASG Name: $ASG_NAME"
echo "  Current capacity: $CURRENT_CAPACITY"
echo "  Desired capacity: $DESIRED_CAPACITY"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Cancelled"
    exit 0
fi

# Scale the ASG
print_info "Scaling ASG to $DESIRED_CAPACITY runners..."
aws autoscaling set-desired-capacity \
    --auto-scaling-group-name "$ASG_NAME" \
    --desired-capacity "$DESIRED_CAPACITY" \
    --honor-cooldown

if [ $? -eq 0 ]; then
    print_info "Successfully scaled to $DESIRED_CAPACITY runners"
    print_info "It may take a few minutes for instances to launch"
else
    print_error "Failed to scale ASG"
    exit 1
fi

# Show current status
echo ""
print_info "Current ASG status:"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --query 'AutoScalingGroups[0].{Desired:DesiredCapacity,Min:MinSize,Max:MaxSize,Current:Instances[*].InstanceId | length(@)}' \
    --output table

