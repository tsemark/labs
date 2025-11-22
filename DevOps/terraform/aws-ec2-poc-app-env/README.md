# EC2 Sample Terraform Project

The usecase is to make local env up as soon as possible for demo purposes or sharing poc

This Terraform project creates an EC2 instance with the following features:

- ✅ Public IP enabled
- ✅ SSH port (22) open for public access
- ✅ HTTP port (80) open for public beta testing
- ✅ SSH key automatically downloaded to local directory
- ✅ Pre-installed software on boot (via user-data):
  - Git
  - Docker
  - Docker Compose

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed (>= 1.0)
3. Appropriate AWS permissions to create EC2 instances, security groups, and key pairs

## Usage

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review the plan:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```

4. **After deployment, SSH to the instance:**
   ```bash
   ssh -i ec2_key.pem ec2-user@<PUBLIC_IP>
   ```
   
   Or use the output command:
   ```bash
   terraform output -raw ssh_command
   ```

5. **Access HTTP service:**
   Open your browser and navigate to: `http://<PUBLIC_IP>`

6. **View outputs:**
   ```bash
   terraform output
   ```

## Configuration

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
aws_region     = "us-east-1"
project_name   = "ec2-sample"
instance_type  = "t2.micro"
volume_size    = 20
```

### Instance Types for 4-8 GB RAM and 2-4 CPU

For instances with 4-8 GB RAM and 2-4 CPU, consider these options:

**2 CPU Options:**
- `t3a.medium` (~$27/month) - 2 vCPU, 4 GB RAM
- `t3.medium` (~$30/month) - 2 vCPU, 4 GB RAM
- `t3a.large` (~$55/month) - 2 vCPU, 8 GB RAM
- `t3.large` (~$61/month) - 2 vCPU, 8 GB RAM
- `m5a.large` (~$63/month) - 2 vCPU, 8 GB RAM

**4 CPU Options:**
- `t3a.xlarge` (~$109/month) - 4 vCPU, 16 GB RAM
- `t3.xlarge` (~$121/month) - 4 vCPU, 16 GB RAM

See `INSTANCE_PRICING.md` for detailed pricing information.

## Outputs

After deployment, Terraform will output:
- `instance_id`: EC2 instance ID
- `instance_public_ip`: Public IP address
- `instance_public_dns`: Public DNS name
- `ssh_command`: Ready-to-use SSH command
- `private_key_path`: Path to the downloaded private key

## SSH Key

The SSH private key (`ec2_key.pem`) is automatically downloaded to the project directory with proper permissions (0600). Keep this file secure!

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Notes

- The security group allows SSH (port 22) and HTTP (port 80) from anywhere (0.0.0.0/0)
- The instance uses the latest Amazon Linux 2 AMI by default
- All software is installed via user-data script during instance boot
- The HTTP server is started automatically for testing purposes
- Docker Buildx 0.17+ is automatically installed and configured (required for `compose build`)
- Docker Compose plugin version is installed for better compatibility

## Pricing
### 2 vCPU Options

| Instance Type | vCPUs | Memory (GB) | Hourly Rate (USD) | Monthly Cost (24/7) | Notes |
|---------------|-------|-------------|-------------------|---------------------|-------|
| **t3.medium** | 2 | 4 | ~$0.0416 | ~$30 | Best for general purpose, burstable |
| **t3a.medium** | 2 | 4 | ~$0.0374 | ~$27 | AMD-based, cheaper than t3 |
| **t3.large** | 2 | 8 | ~$0.0832 | ~$61 | Burstable, 8GB RAM |
| **t3a.large** | 2 | 8 | ~$0.0748 | ~$55 | AMD-based, 8GB RAM |
| **m5.large** | 2 | 8 | ~$0.096 | ~$70 | General purpose, dedicated baseline |
| **m5a.large** | 2 | 8 | ~$0.0864 | ~$63 | AMD-based, dedicated baseline |

### 4 vCPU Options

| Instance Type | vCPUs | Memory (GB) | Hourly Rate (USD) | Monthly Cost (24/7) | Notes |
|---------------|-------|-------------|-------------------|---------------------|-------|
| **t3.xlarge** | 4 | 16 | ~$0.1664 | ~$121 | More RAM than needed (16GB) |
| **t3a.xlarge** | 4 | 16 | ~$0.1496 | ~$109 | AMD-based, more RAM than needed |
| **m5.xlarge** | 4 | 16 | ~$0.192 | ~$140 | More RAM than needed (16GB) |
| **m5a.xlarge** | 4 | 16 | ~$0.1728 | ~$126 | AMD-based, more RAM than needed |