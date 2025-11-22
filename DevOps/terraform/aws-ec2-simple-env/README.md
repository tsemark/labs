# Application & Database Infrastructure

## TLDR
```
terraform init
terraform apply --var-file terraform.test.tfvars

terraform destroy # cleanup
```

This Terraform configuration creates a cost-optimized infrastructure for a simple application with a database.

## Architecture

- **VPC**: Custom VPC with public and private subnets
- **Public Subnets**: Host EC2 application instances (2 subnets across 2 AZs for high availability)
- **Private Subnets**: Host RDS database (2 subnets across 2 AZs, required by RDS)
- **Application Load Balancer**: Distributes traffic across EC2 instances
- **EC2 Instances**: 2 instances running the application (for high availability)
- **RDS Database**: MySQL database in private subnet
- **Security Groups**: Separate security groups for ALB, app, and database

## Cost Optimization Features

✅ **No NAT Gateway**: App instances are in public subnets to avoid NAT Gateway costs (~$32/month + data transfer)

✅ **Single AZ RDS**: Database runs in single availability zone (Multi-AZ disabled) to save costs

✅ **Small Instance Types**: Defaults to `t3.micro` for EC2 and `db.t3.micro` for RDS

✅ **Application Load Balancer**: More cost-effective than Classic Load Balancer

✅ **GP3 Storage**: Uses gp3 storage type for better price/performance

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed (>= 1.0)
3. Appropriate AWS permissions to create:
   - VPC, subnets, route tables, internet gateway
   - EC2 instances, security groups, key pairs
   - RDS instances, DB subnet groups
   - Application Load Balancer, target groups

## Usage

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` and set your database password:**
   ```hcl
   db_password = "YourSecurePassword123!"
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **Access your application:**
   ```bash
   terraform output alb_url
   ```

## Configuration

### Key Variables

- `instance_type`: EC2 instance type (default: `t3.micro` for cost optimization)
- `db_instance_class`: RDS instance class (default: `db.t3.micro` for cost optimization)
- `app_port`: Port on which your application runs (default: 3000)
- `db_password`: Database master password (REQUIRED - set in terraform.tfvars)

### Cost Estimates (Monthly)

With default settings in `ap-southeast-1`:
- 2x EC2 t3.micro: ~$15/month
- 1x RDS db.t3.micro: ~$15/month
- Application Load Balancer: ~$16/month + data transfer
- Storage (20GB gp3): ~$2/month
- **Total: ~$48-50/month** (excluding data transfer)

For even lower costs, consider:
- Using `t3a.micro` instead of `t3.micro` (slightly cheaper)
- Using `db.t4g.micro` for RDS if ARM is acceptable (cheaper)
- Reducing storage sizes if not needed

## Network Architecture

```
Internet
   │
   ├─ Internet Gateway
   │
   ├─ Public Subnet 1 (AZ-1)
   │   ├─ EC2 App Instance 1
   │   └─ ALB Subnet
   │
   ├─ Public Subnet 2 (AZ-2)
   │   ├─ EC2 App Instance 2
   │   └─ ALB Subnet
   │
   └─ Private Subnet 1 (AZ-1)
       └─ RDS Database (Primary)
   └─ Private Subnet 2 (AZ-2)
       └─ RDS Database (Standby - for Multi-AZ, currently disabled)
```

## Security

- **Database**: Only accessible from application security group (private subnet)
- **Application**: Accessible only through Load Balancer (HTTP/HTTPS from internet)
- **SSH**: Only accessible from within VPC (for security)
- **No NAT Gateway**: App instances in public subnets can access internet directly





