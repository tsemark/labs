# GitHub Self-Hosted Runners on AWS

This Terraform configuration deploys scalable GitHub Actions self-hosted runners on AWS using the [terraform-aws-github-runner](https://github.com/github-aws-runners/terraform-aws-github-runner) module.

## Features

- ✅ **Auto Scaling Group (ASG)** - Automatic scaling based on job demand
- ✅ **Scheduled Scaling** - 9 AM to 5 PM HKT on weekdays only
- ✅ **Dynamic Runners** - Scale up to X runners based on job queue
- ✅ **Standby Runners** - Always-on runners for immediate job pickup
- ✅ **Custom AMI Support** - Use Packer-built AMIs for faster startup
- ✅ **Easy Manual Scaling** - Scale runners via AWS Console or CLI

## Architecture

### Runner Types

1. **Dynamic Runners**
   - Scale based on GitHub Actions job queue
   - Scheduled scaling: 9 AM - 5 PM HKT on weekdays
   - Scales down to 0 outside business hours
   - Can scale up to `max_runners` when needed

2. **Standby Runners**
   - Always running for immediate job pickup
   - Fixed capacity (configurable min/max)
   - Reduces job wait time

### Scheduled Scaling Schedule

- **9 AM HKT (1 AM UTC)** - Scale up to 1 runner on weekdays
- **5 PM HKT (9 AM UTC)** - Scale down to 0 runners on weekdays
- **Weekends** - Runners scale down to 0 (no weekend runs)
- **Monday Morning** - Automatically scale up at 9 AM HKT

## Pros and Cons

### ✅ Pros of Using terraform-aws-github-runner Module

1. **Production-Ready Solution**
   - Battle-tested module used by many organizations
   - Handles edge cases and error scenarios
   - Regular updates and community support
   - Comprehensive documentation

2. **Automatic Scaling**
   - Built-in Lambda functions for intelligent scaling
   - Monitors GitHub Actions queue depth
   - Automatically scales up/down based on demand
   - Reduces manual intervention

3. **Comprehensive Infrastructure**
   - Pre-configured SQS queues for job management
   - Lambda functions for lifecycle management
   - Proper IAM roles and policies
   - Security best practices built-in

4. **Flexible Configuration**
   - Support for multiple runner groups (dynamic, standby)
   - Custom AMI support
   - Spot instance support
   - Configurable scaling policies

5. **Cost Optimization**
   - Automatic scale-down when idle
   - Support for spot instances
   - Efficient resource utilization
   - Pay only for what you use

6. **Monitoring and Logging**
   - CloudWatch integration
   - SQS queue metrics
   - Lambda function logs
   - Easy troubleshooting

7. **Webhook Support**
   - Optional webhook for real-time scaling
   - Faster response to job events
   - Better integration with GitHub

### ❌ Cons of Using terraform-aws-github-runner Module

1. **Complexity**
   - More moving parts (Lambda, SQS, EventBridge)
   - Harder to understand for beginners
   - More resources to manage
   - Steeper learning curve

2. **Module Dependency**
   - Relies on external module maintenance
   - Potential breaking changes in updates
   - Less control over implementation details
   - Version compatibility concerns

3. **Resource Overhead**
   - Additional Lambda functions (cost)
   - SQS queues and EventBridge rules
   - More IAM roles and policies
   - Higher initial setup complexity

4. **Limited Customization**
   - Must work within module constraints
   - Some features may not be configurable
   - Harder to customize deeply
   - Module updates may change behavior

5. **Cold Start Latency**
   - Lambda functions have cold starts
   - SQS polling may have delays
   - Not instant scaling (few seconds delay)
   - May miss very short-lived jobs

6. **Cost Considerations**
   - Lambda invocations add cost
   - SQS requests have costs
   - More CloudWatch metrics
   - Additional infrastructure costs

7. **Debugging Complexity**
   - Issues can span multiple services
   - Need to check Lambda logs, SQS, ASG
   - More complex troubleshooting
   - Requires understanding of multiple AWS services

## Comparison: Module Approach vs. Direct EC2/ASG Approach

### terraform-aws-github-runner Module (Current Approach)

**Architecture:**
- EC2 Auto Scaling Groups
- Lambda functions for scaling logic
- SQS queues for job management
- EventBridge/CloudWatch Events
- GitHub App authentication

**Best For:**
- Production environments
- Organizations needing automatic scaling
- Teams wanting minimal maintenance
- High job volume scenarios
- Cost optimization through auto-scaling

**Key Characteristics:**
| Aspect | Details |
|-------|---------|
| Setup Complexity | Medium-High (module handles complexity) |
| Maintenance | Low (module updates) |
| Scaling Intelligence | High (queue-based, automatic) |
| Cost Efficiency | High (auto scale-down, spot support) |
| Customization | Medium (module constraints) |
| Learning Curve | Medium (need to understand module) |
| Resource Count | High (~15-20 resources) |
| Operational Overhead | Low (automated) |

### Direct EC2/ASG Approach (Alternative)

**Architecture:**
- EC2 Auto Scaling Groups
- User-data scripts for runner setup
- GitHub Personal Access Token or App
- Manual or simple scheduled scaling
- CloudWatch alarms for scaling

**Best For:**
- Simple use cases
- Full control requirements
- Custom scaling logic
- Learning/experimentation
- Organizations with specific requirements

**Key Characteristics:**
| Aspect | Details |
|-------|---------|
| Setup Complexity | Low-Medium (direct control) |
| Maintenance | High (manual updates) |
| Scaling Intelligence | Low-Medium (manual/scheduled) |
| Cost Efficiency | Medium (requires manual optimization) |
| Customization | High (full control) |
| Learning Curve | Low (standard AWS services) |
| Resource Count | Low (~5-8 resources) |
| Operational Overhead | High (manual management) |

### Detailed Comparison

#### Setup and Configuration

**Module Approach:**
- ✅ Pre-configured with best practices
- ✅ Handles GitHub App setup automatically
- ✅ Built-in security configurations
- ❌ Requires understanding module structure
- ❌ Less flexibility in initial setup

**Direct EC2/ASG Approach:**
- ✅ Full control over configuration
- ✅ Simple, straightforward setup
- ✅ Easy to understand and modify
- ❌ Must implement security best practices
- ❌ More manual configuration needed

#### Scaling Behavior

**Module Approach:**
- ✅ Intelligent queue-based scaling
- ✅ Automatic scale-up on job demand
- ✅ Automatic scale-down when idle
- ✅ Configurable scaling policies
- ❌ Slight delay due to Lambda/SQS
- ❌ More complex scaling logic

**Direct EC2/ASG Approach:**
- ✅ Simple scheduled scaling
- ✅ Direct control over scaling triggers
- ✅ Can implement custom logic
- ❌ Requires manual scaling configuration
- ❌ Less intelligent (no queue awareness)

#### Cost Management

**Module Approach:**
- ✅ Automatic cost optimization
- ✅ Efficient resource utilization
- ✅ Built-in spot instance support
- ✅ Pay-per-use model
- ❌ Additional Lambda/SQS costs
- ❌ More resources = more costs

**Direct EC2/ASG Approach:**
- ✅ Lower infrastructure overhead
- ✅ Direct cost control
- ✅ No Lambda/SQS costs
- ❌ Manual cost optimization needed
- ❌ Risk of over-provisioning

#### Maintenance and Updates

**Module Approach:**
- ✅ Module handles updates
- ✅ Community-driven improvements
- ✅ Security patches via module updates
- ❌ Dependent on module maintainers
- ❌ Potential breaking changes

**Direct EC2/ASG Approach:**
- ✅ Full control over updates
- ✅ No external dependencies
- ✅ Custom update processes
- ❌ Manual maintenance required
- ❌ Must track security updates

#### Troubleshooting

**Module Approach:**
- ✅ Comprehensive logging
- ✅ Well-documented issues
- ✅ Community support
- ❌ More complex debugging
- ❌ Multiple services to check

**Direct EC2/ASG Approach:**
- ✅ Simpler debugging
- ✅ Direct access to logs
- ✅ Easier to trace issues
- ❌ Less documentation
- ❌ Must implement own logging

### When to Choose Each Approach

**Choose Module Approach When:**
- You need production-grade solution
- Automatic scaling is important
- You want minimal maintenance
- Cost optimization is critical
- You have high job volumes
- Team lacks deep AWS expertise

**Choose Direct EC2/ASG Approach When:**
- You need full control
- Simple use case (fixed number of runners)
- Custom requirements not met by module
- Learning/experimentation
- Minimal infrastructure overhead needed
- Team has strong AWS expertise

### Hybrid Approach

You can also combine both:
- Use module for dynamic runners (auto-scaling)
- Use direct EC2/ASG for standby runners (simple, always-on)
- Best of both worlds

## Comparison: EC2 Self-Hosted Runners vs. Kubernetes ACR (Actions Runner Controller)

### EC2 Self-Hosted Runners (Current Approach)

**Architecture:**
- EC2 instances in Auto Scaling Groups
- Lambda functions for scaling logic
- SQS queues for job management
- GitHub App authentication
- Direct VM-based runners

**Best For:**
- AWS-native environments
- Teams familiar with EC2/ASG
- Organizations wanting VM-level isolation
- Workloads requiring persistent storage
- Long-running jobs
- Full control over instance configuration

**Key Characteristics:**
| Aspect | Details |
|-------|---------|
| Infrastructure | AWS EC2, ASG, Lambda, SQS |
| Scaling Unit | EC2 Instances (VMs) |
| Isolation | VM-level (full isolation) |
| Startup Time | 30-60 seconds (with custom AMI) |
| Resource Efficiency | Lower (entire VM per runner) |
| Cost Model | Per-instance-hour pricing |
| Storage | Persistent EBS volumes |
| Networking | VPC, Security Groups |
| Management | Terraform, AWS Console |
| Learning Curve | Medium (AWS services) |

### Kubernetes ACR (Actions Runner Controller)

**Architecture:**
- Kubernetes Pods (containers)
- Kubernetes HPA (Horizontal Pod Autoscaler)
- Custom Resources (RunnerSet, RunnerDeployment)
- GitHub App authentication
- Container-based runners

**Best For:**
- Kubernetes-native environments
- Teams already using Kubernetes
- Containerized workloads
- High-density runner deployments
- Organizations with existing K8s infrastructure
- Microservices architectures

**Key Characteristics:**
| Aspect | Details |
|-------|---------|
| Infrastructure | Kubernetes cluster, ACR operator |
| Scaling Unit | Kubernetes Pods (containers) |
| Isolation | Container-level (namespace isolation) |
| Startup Time | 10-20 seconds (container startup) |
| Resource Efficiency | Higher (shared cluster resources) |
| Cost Model | Per-pod resource usage |
| Storage | Ephemeral or PVCs |
| Networking | Kubernetes networking, CNI |
| Management | kubectl, Helm, GitOps |
| Learning Curve | Medium-High (Kubernetes knowledge) |

### Detailed Comparison

#### Infrastructure Requirements

**EC2 Approach:**
- ✅ No Kubernetes cluster needed
- ✅ Simpler infrastructure stack
- ✅ Direct AWS integration
- ✅ Works with minimal setup
- ❌ Requires AWS account and VPC
- ❌ More AWS services to manage

**Kubernetes ACR Approach:**
- ✅ Leverages existing K8s cluster
- ✅ Unified infrastructure platform
- ✅ Better resource utilization
- ✅ Works across cloud providers
- ❌ Requires Kubernetes cluster (EKS, GKE, AKS, etc.)
- ❌ More complex initial setup

#### Resource Efficiency

**EC2 Approach:**
- ✅ Full VM resources per runner
- ✅ Predictable resource allocation
- ✅ No resource contention
- ✅ Better for resource-intensive jobs
- ❌ Lower density (1 runner per VM typically)
- ❌ Higher cost for low utilization

**Kubernetes ACR Approach:**
- ✅ Higher density (multiple runners per node)
- ✅ Better resource utilization
- ✅ Shared cluster resources
- ✅ Cost-effective for many small jobs
- ❌ Resource contention possible
- ❌ Need to manage resource limits

#### Scaling Behavior

**EC2 Approach:**
- ✅ ASG-based scaling (proven, reliable)
- ✅ Lambda-driven intelligent scaling
- ✅ SQS queue-based scaling decisions
- ✅ Configurable min/max instances
- ❌ Slower scaling (VM provisioning)
- ❌ Coarser scaling granularity

**Kubernetes ACR Approach:**
- ✅ Faster scaling (container startup)
- ✅ HPA-based automatic scaling
- ✅ Finer scaling granularity
- ✅ Kubernetes-native scaling
- ❌ Depends on cluster capacity
- ❌ May need cluster autoscaling

#### Isolation and Security

**EC2 Approach:**
- ✅ VM-level isolation (strong)
- ✅ Separate security groups per runner
- ✅ Full control over network isolation
- ✅ Better for security-sensitive workloads
- ❌ More resources per isolated unit
- ❌ Higher cost for isolation

**Kubernetes ACR Approach:**
- ✅ Namespace-level isolation
- ✅ Pod security policies
- ✅ Network policies for isolation
- ✅ Resource quotas per namespace
- ❌ Container-level isolation (weaker)
- ❌ Shared kernel concerns

#### Cost Analysis

**EC2 Approach:**
- ✅ Predictable per-instance costs
- ✅ Spot instance support
- ✅ Pay only for running instances
- ✅ Easy cost estimation
- ❌ Higher minimum cost (entire VM)
- ❌ Less efficient for small jobs

**Kubernetes ACR Approach:**
- ✅ Better cost efficiency (shared nodes)
- ✅ Pay for actual resource usage
- ✅ Cluster resource sharing
- ✅ Lower cost for many small jobs
- ❌ Cluster costs (even when idle)
- ❌ More complex cost allocation

#### Startup Time

**EC2 Approach:**
- ✅ 30-60 seconds with custom AMI
- ✅ 2-5 minutes with user-data provisioning
- ✅ Predictable startup time
- ✅ Can pre-warm instances
- ❌ Slower than containers
- ❌ Cold start latency

**Kubernetes ACR Approach:**
- ✅ 10-20 seconds (container startup)
- ✅ Faster job pickup
- ✅ Quicker scaling response
- ✅ Better for short jobs
- ❌ Depends on image pull time
- ❌ Node capacity constraints

#### Storage and Persistence

**EC2 Approach:**
- ✅ Persistent EBS volumes
- ✅ Full disk access
- ✅ Large storage capacity
- ✅ Better for build artifacts
- ✅ Can persist between jobs
- ❌ Storage costs per instance
- ❌ Slower cleanup

**Kubernetes ACR Approach:**
- ✅ Ephemeral storage (default)
- ✅ PVCs for persistence
- ✅ Shared storage options
- ✅ Faster cleanup
- ❌ Limited by PVC size
- ❌ Storage class dependencies

#### Management and Operations

**EC2 Approach:**
- ✅ Terraform for infrastructure
- ✅ AWS Console for management
- ✅ Familiar AWS tooling
- ✅ CloudWatch for monitoring
- ✅ Simple debugging (SSH access)
- ❌ More AWS services to learn
- ❌ Separate management tools

**Kubernetes ACR Approach:**
- ✅ kubectl for management
- ✅ GitOps-friendly (ArgoCD, Flux)
- ✅ Kubernetes-native tooling
- ✅ Unified platform management
- ✅ Declarative configuration
- ❌ Requires Kubernetes expertise
- ❌ More complex debugging

#### Customization and Flexibility

**EC2 Approach:**
- ✅ Full VM customization
- ✅ Custom AMIs with any software
- ✅ Full root access
- ✅ Any OS or configuration
- ✅ Easy to add tools/packages
- ❌ Requires AMI rebuilds
- ❌ Slower update cycle

**Kubernetes ACR Approach:**
- ✅ Container image customization
- ✅ Easy to update images
- ✅ Version control for images
- ✅ Fast image updates
- ✅ CI/CD for images
- ❌ Limited to container capabilities
- ❌ Need container expertise

#### High Availability

**EC2 Approach:**
- ✅ Multi-AZ support
- ✅ ASG handles failures
- ✅ Instance replacement
- ✅ VPC-level HA
- ❌ Single region typically
- ❌ Instance-level failures

**Kubernetes ACR Approach:**
- ✅ Multi-node cluster
- ✅ Pod rescheduling
- ✅ Cluster-level HA
- ✅ Cross-zone distribution
- ❌ Cluster-level failures
- ❌ Node capacity dependencies

#### Monitoring and Observability

**EC2 Approach:**
- ✅ CloudWatch metrics
- ✅ CloudWatch Logs
- ✅ AWS-native monitoring
- ✅ Instance-level metrics
- ✅ Simple alerting
- ❌ Separate monitoring stack
- ❌ Less integrated

**Kubernetes ACR Approach:**
- ✅ Prometheus/Grafana integration
- ✅ Kubernetes metrics
- ✅ Unified observability
- ✅ Pod-level metrics
- ✅ Better integration
- ❌ Requires monitoring setup
- ❌ More complex setup

### When to Choose Each Approach

**Choose EC2 Approach When:**
- You're primarily on AWS
- You need VM-level isolation
- You have long-running jobs
- You need persistent storage
- You want simple, proven infrastructure
- Your team knows AWS better than K8s
- You need full control over instances
- You have resource-intensive workloads

**Choose Kubernetes ACR Approach When:**
- You already have a Kubernetes cluster
- You want higher resource density
- You have many short-running jobs
- You're using containerized workflows
- Your team has Kubernetes expertise
- You want GitOps workflows
- You need faster scaling
- You want unified infrastructure

### Hybrid Approach

You can also use both:
- **EC2 runners** for heavy/long jobs, security-sensitive workloads
- **Kubernetes ACR** for lightweight jobs, high-frequency builds
- Route jobs to appropriate runner type based on labels
- Best of both worlds

### Migration Considerations

**From EC2 to Kubernetes ACR:**
- Requires Kubernetes cluster setup
- Need to containerize runner images
- Different scaling mechanisms
- Network configuration changes
- Storage migration considerations

**From Kubernetes ACR to EC2:**
- Simpler infrastructure (no K8s needed)
- Better isolation for security
- More predictable costs
- Easier for teams without K8s expertise

## Prerequisites

1. **GitHub App** - Create a GitHub App for authentication
   - Go to: `https://github.com/organizations/YOUR_ORG/settings/apps`
   - Create a new app with the following permissions:
     - Repository permissions:
       - Actions: Read/Write
       - Metadata: Read-only
   - Generate a private key and download it
   - Note the App ID

2. **AWS Account** - Configure AWS credentials
   ```bash
   aws configure
   ```

3. **Terraform** - Install Terraform (>= 1.0)
   ```bash
   brew install terraform  # macOS
   ```

4. **Custom AMI (Optional)** - Build AMI using Packer
   ```bash
   cd ../packer/self-hosted-runners
   packer init .
   packer build main.pkr.hcl
   ```

## Quick Start

1. **Clone and navigate to the directory**
   ```bash
   cd DevOps/terraform/aws-self-hosted-runner
   ```

2. **Copy the example variables file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit `terraform.tfvars` with your configuration**
   ```hcl
   github_app_id         = "your-app-id"
   github_app_key_base64 = "base64-encoded-private-key"
   vpc_id                = "vpc-xxxxx"
   subnet_ids            = ["subnet-xxxxx"]
   ```

4. **Initialize Terraform**
   ```bash
   terraform init
   ```

5. **Plan the deployment**
   ```bash
   terraform plan
   ```

6. **Apply the configuration**
   ```bash
   terraform apply
   ```

## Configuration

### Required Variables

- `github_app_id` - GitHub App ID
- `github_app_key_base64` - Base64 encoded GitHub App private key
- `vpc_id` - VPC ID where runners will be launched
- `subnet_ids` - List of subnet IDs (at least one)

### Key Configuration Options

#### Instance Types
```hcl
instance_type  = "t4g.xlarge"  # For dynamic runners
standby_instance_type = "t4g.xlarge"  # For standby runners
```

#### Scaling Limits
```hcl
min_runners = 0   # Minimum dynamic runners
max_runners = 10  # Maximum dynamic runners (can scale up to this)
standby_min_runners = 1  # Minimum standby runners
standby_max_runners = 3  # Maximum standby runners
```

#### Custom AMI
```hcl
use_custom_ami = true  # Use Packer-built AMI
```

#### Capacity Type
```hcl
capacity_type = "ON_DEMAND"  # or "SPOT" for cost savings
```

## Manual Scaling

### Via AWS Console

1. Go to EC2 → Auto Scaling Groups
2. Select the dynamic runners ASG
3. Edit → Desired capacity
4. Set to desired number of runners

### Via AWS CLI

```bash
# Get ASG name from outputs
ASG_NAME=$(terraform output -raw dynamic_runners_autoscaling_group_name)

# Scale to 5 runners
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name $ASG_NAME \
  --desired-capacity 5
```

### Via Terraform

You can also update the `min_runners` variable and apply:

```bash
terraform apply -var="min_runners=5"
```

## Scheduled Scaling Details

The scheduled scaling is configured for **Hong Kong Time (HKT)**:

- **9 AM HKT** = 1 AM UTC (scale up to 1 runner)
- **5 PM HKT** = 9 AM UTC (scale down to 0 runners)
- **Weekdays only** (Monday - Friday)
- **Weekends** - Runners scale down to 0

To modify the schedule, edit the `aws_autoscaling_schedule` resources in `main.tf`.

## Cost Optimization

1. **Use Spot Instances** - Set `capacity_type = "SPOT"` for cost savings
2. **Adjust Standby Runners** - Reduce `standby_min_runners` if not needed
3. **Tighten Scaling Limits** - Set appropriate `max_runners` based on actual needs
4. **Custom AMI** - Use Packer-built AMI to reduce startup time and costs

## Monitoring

### CloudWatch Metrics

- Auto Scaling Group metrics (CPU, Network, etc.)
- Runner queue depth (via SQS)
- Lambda function metrics (scaling functions)

### View Runner Status

```bash
# Get runner ASG names
terraform output

# Check current capacity
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $(terraform output -raw dynamic_runners_autoscaling_group_name) \
  --query 'AutoScalingGroups[0].{Desired:DesiredCapacity,Min:MinSize,Max:MaxSize}'
```

## Troubleshooting

### Runners Not Starting

1. Check GitHub App permissions
2. Verify VPC/subnet configuration
3. Check security group rules
4. Review CloudWatch logs for Lambda functions

### Scaling Not Working

1. Verify scheduled actions in ASG
2. Check SQS queue for job messages
3. Review Lambda function logs
4. Ensure GitHub webhook is configured (if using webhook)

### Custom AMI Issues

1. Verify AMI exists in the region
2. Check AMI permissions (if using shared AMI)
3. Ensure AMI has runner agent pre-installed

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note:** This will delete all runners, ASGs, and related resources. Make sure you have backups if needed.

## References

- [terraform-aws-github-runner Module](https://github.com/github-aws-runners/terraform-aws-github-runner)
- [GitHub Actions Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [AWS Auto Scaling Groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html)
- [Packer AMI Build](../packer/self-hosted-runners/README.md)

## License

This configuration is provided as-is for use in your infrastructure.

