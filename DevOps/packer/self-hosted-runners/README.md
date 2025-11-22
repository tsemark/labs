# GitHub Actions Self-Hosted Runner AMI

This Packer configuration creates a pre-provisioned Amazon Machine Image (AMI) for GitHub Actions self-hosted runners. The AMI includes all necessary dependencies and tools pre-installed, eliminating the need for runtime provisioning via user-data scripts.

## Overview

Instead of installing dependencies on-the-fly when EC2 instances are launched (using user-data scripts), this approach pre-bakes all required software into a custom AMI. This significantly reduces instance startup time and ensures consistent runner environments.

## What's Included ( Base on user usecase)

The AMI is built on Ubuntu and includes:

- **GitHub Actions Runner Agent** (v2.319.1) - Pre-installed in `/opt/action-runner`
- **AWS CLI v2** - Latest version for ARM64 architecture
- **Docker** - Docker Engine, CLI, containerd, Buildx, and Docker Compose
- **GitHub CLI (gh)** - For GitHub API interactions
- **Kustomize** - Kubernetes configuration management tool
- **System Dependencies** - libssl-dev, zlib1g, libkrb5-3, libicu70, unzip, ca-certificates, curl

## Architecture

- **Instance Type**: `t4g.xlarge` (ARM64/Graviton2)
- **Region**: `ap-east-1` (Asia Pacific - Hong Kong)
- **Base AMI**: Ubuntu (ARM64)
- **Volume**: 10GB GP3 EBS volume
- **SSH User**: `ubuntu`

## Prerequisites

- [Packer](https://www.packer.io/downloads) installed (version 1.2.8 or later)
- AWS credentials configured 
- Appropriate IAM permissions to create AMIs and launch EC2 instances

## Usage

### Build the AMI

**Option 1: Using command-line flags** (quick testing):
```bash
packer init .
packer build \
  -var 'gh_runner_url=https://github.com/YOUR_ORG/YOUR_REPO' \
  -var 'gh_runner_token=YOUR_RUNNER_TOKEN' \
  main.pkr.hcl
```

**Option 2: Using environment variables** (recommended for CI/CD):
```bash
export PKR_VAR_gh_runner_url="https://github.com/YOUR_ORG/YOUR_REPO"
export PKR_VAR_gh_runner_token="YOUR_RUNNER_TOKEN"
packer init .
packer build main.pkr.hcl
```

### Customize Configuration

Before building, you may want to modify:

- **Region**
- **Source AMI**
- **Instance Type**
- **Runner Version**
- **Tool Versions**
- **Additional Tools Base on your need**

## Pros and Cons

### ✅ Pros of Pre-Provisioned AMI Approach

1. **Faster Instance Startup**
   - No time spent downloading and installing packages during launch
   - Instances are ready to run jobs almost immediately
   - Reduces cold start latency for runners

2. **Consistent Environment**
   - All runners use identical software versions
   - Eliminates variability from network issues during provisioning
   - Easier to debug issues with a known-good baseline

3. **Reduced Network Dependency**
   - No reliance on external package repositories during launch
   - Works better in VPCs with restricted internet access
   - Less susceptible to transient network failures

4. **Cost Efficiency**
   - Faster startup means less idle time waiting for provisioning
   - Can use smaller instance types if provisioning was the bottleneck
   - Better utilization of spot instances

5. **Security Benefits**
   - Can audit and harden the image once
   - Easier to apply security patches in a controlled manner
   - Reduced attack surface during instance launch

6. **Version Control**
   - AMI versioning provides clear rollback points
   - Can maintain multiple AMI versions for different needs
   - Better change management and testing

### ❌ Cons of Pre-Provisioned AMI Approach

1. **AMI Maintenance Overhead**
   - Must rebuild AMI when software versions need updates
   - Requires separate process to keep dependencies current
   - More complex CI/CD pipeline for AMI updates

2. **Slower Update Cycle**
   - Changes require AMI rebuild and deployment
   - Cannot easily test new tool versions on-the-fly
   - Less flexibility for experimentation

3. **Storage Costs**
   - Custom AMIs consume EBS snapshot storage
   - Multiple AMI versions increase storage costs
   - Need AMI lifecycle management strategy

4. **Build Time**
   - Initial AMI build takes time (typically 10-20 minutes)
   - Must account for build time in update workflows
   - Requires dedicated build infrastructure or CI/CD setup

5. **Region Limitations**
   - Must build AMI in each target region
   - Cross-region AMI copying adds complexity
   - Regional AMI management overhead

6. **Less Dynamic Configuration**
   - Harder to customize per-instance or per-environment
   - May need multiple AMI variants for different use cases
   - Less suitable for highly variable requirements

## When to Use This Approach

**Best suited for:**
- High-frequency runner launches (Auto Scaling Groups, spot fleets)
- Environments requiring fast startup times
- Organizations with stable tool requirements
- Production workloads needing consistency
- Cost-sensitive scenarios where faster startup reduces costs

**Consider alternatives (user-data) when:**
- Tool versions change frequently
- Need per-instance customization
- Low launch frequency (cost of AMI maintenance > savings)
- Experimental or rapidly evolving requirements
- Limited storage budget for AMI snapshots

## Maintenance

### Updating the AMI

1. Update version numbers in `provision.sh`
2. Rebuild the AMI: `packer build main.pkr.hcl`
3. Update your launch templates/ASG configurations with the new AMI ID
4. Test the new AMI before full deployment

### Recommended Update Schedule

- **Security patches**: As soon as available
- **Runner agent**: Monthly or when new features are needed
- **Tool versions**: Quarterly or as needed for compatibility
- **Base AMI**: When Ubuntu releases new LTS versions


