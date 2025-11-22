### [Financial Institution Startup Cost Saving Experience]

# Cost Optimization 

## Executive Summary

This document outlines the cost optimization initiatives, successfully reducing monthly infrastructure costs from **$11,000 USD** to **$6,000 USD** across all environments (DEV, UAT, and PROD). This represents a **45% cost reduction** while maintaining service quality and performance.

## Background

### Initial State
- **Monthly Infrastructure Cost**: $11,000 USD
- **Environments**: DEV, UAT, PROD
- **CI/CD**: Jenkins Pipeline
- **Infrastructure**: AMD-based instances across the board

### Objective
Reduce monthly infrastructure costs to **$6,000 USD** (target: ~45% reduction) without compromising:
- Application performance
- Build times
- System reliability
- Developer productivity

## Cost Optimization Strategies

### 1. Resource Cleanup and High Availability Optimization

#### Approach
- **Removed Unused Resources**: Conducted comprehensive audit to identify and remove idle or unnecessary resources
- **Optimized High Availability**: Scaled down over-provisioned HA configurations where appropriate

#### Key Actions and BAUs
- Identified and terminated unused EC2 instances
- Removed orphaned EBS volumes and snapshots
- Consolidated underutilized RDS instances
- Optimized CloudWatch log retention policies
- Removed unused Elastic IP addresses
- Scaledown High Availability Requirement for non production environments ( example Opensearch, RDS and etc) while maintaining adequate performance

### 2. CI/CD Infrastructure Optimization

#### Problem Statement
The initial CI/CD implementation used Jenkins and migrate to GHA our 1st approach is using Kubernetes Actions Runner Controller (ARC) on the same cluster where applications were running, creating a dedicated CI/CD cluster was not an opion. This approach had several limitations:
- **Build Time Impact**: Running CI/CD jobs on application nodes caused resource contention
- **Performance Degradation**: Application performance was affected during build processes
- **Resource Limitation**: Due to CI/CD resource consumption. application was impacted
- **Long Build Times**: 
  - Backend (ASP.NET): 5 minutes on ARC
  - Node.js applications: 10 minutes on ARC

#### Solution: Dedicated EC2 Self-Hosted Runners
We migrated from Kubernetes ARC to dedicated EC2 instances managed by Auto Scaling Groups (ASG) for GitHub Actions runners.

**Why EC2 over ARC?**
- **Isolation**: Dedicated runners prevent resource contention with application workloads
- **Performance**: Faster build times due to dedicated resources
- **Simplicity**: No need to implement Kubernetes affinity rules or node selectors
- **Cost Efficiency**: Pay only for runners when they're needed

#### Results
- **Backend (ASP.NET) Build Time**: Reduced from **5 minutes to 2 minutes or less** (60% improvement)
- **Node.js Build Time**: Reduced from **10 minutes to 5 minutes** (50% improvement)
- **Application Performance**: No longer impacted by CI/CD workloads
- **Developer Productivity**: Faster feedback loops and shorter development cycles

#### Architecture Details
- **Infrastructure**: EC2 instances in Auto Scaling Groups
- **Scaling Strategy**: Combination of scheduled and dynamic scaling
- **Instance Types**: Optimized based on workload requirements
- **Cost Management**: Automated scale-down during non-working hours
- **Active and Passive Runners**: Reducing boot and startup time of the runners

### 3. Runner Cost Management

#### Scheduled Scaling
Implemented time-based scaling to reduce costs during non-working hours:

**Configuration:**
- **Scale Up**: During working hours (9 AM - 5 PM HKT, weekdays)
- **Scale Down**: Outside working hours and weekends
- **Implementation**: AWS Auto Scaling Group scheduled actions

**Benefits:**
- Automatic cost reduction during idle periods
- Runners available when needed
- No manual intervention required

#### Dynamic Scaling
Added intelligent scaling based on actual demand:

**Features:**
- **Queue-Based Scaling**: Monitors GitHub Actions job queue depth
- **Automatic Scale-Up**: Adds runners when job queue grows
- **Automatic Scale-Down**: Removes runners when queue is empty
- **High Demand Handling**: Scales up during peak hours automatically

**Cost Impact:**
- Runners only run when jobs are queued
- Automatic cleanup after job completion
- Prevents over-provisioning during low-demand periods


### 4. ARM-Based Architecture Migration

#### Initiative
Migrated all infrastructure from AMD-based (x86) instances to ARM-based (Graviton) instances.

#### Cost Savings
- **Reduction**: Up to **20% cost savings** on compute resources
- **Performance**: Comparable or better performance for most workloads
- **Compatibility**: Verified application compatibility with ARM architecture

#### Implementation Details
- **Instance Types**: Migrated from AMD instances (e.g., `m5a`, `t3a`) to ARM instances (e.g., `m6g`, `t4g`)
- **Testing**: Comprehensive testing to ensure application compatibility
- **Gradual Rollout**: Migrated environments incrementally (DEV → UAT → PROD)
- **Monitoring**: Close monitoring of performance metrics during migration

#### ARM vs AMD Comparison
| Aspect | AMD (Before) | ARM (After) | Benefit |
|--------|-------------|-------------|---------|
| Cost | Baseline | ~20% lower | Significant savings |
| Performance | Good | Comparable/Better | Maintained or improved |
| Compatibility | Universal | Requires testing | Verified for our stack |

## Results and Metrics

### Cost Reduction Summary

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| **Monthly Cost** | $11,000 | $6,000 | **$5,000 (45%)** |
| **Backend Build Time** | 5 min | 2 min | **60% faster** |
| **Node.js Build Time** | 10 min | 5 min | **50% faster** |
| **Compute Cost** | Baseline | -20% | **ARM migration** |

### Key Achievements
- ✅ **45% cost reduction** achieved (target met)
- ✅ **Build times reduced by 50-60%** (unexpected benefit)
- ✅ **Zero downtime** during migrations
- ✅ **No performance degradation** in applications
- ✅ **Improved developer experience** with faster CI/CD

### Cost Breakdown by Initiative

1. **Resource Cleanup**: ~15% reduction
2. **HA Optimization**: ~10% reduction
3. **CI/CD Optimization**: ~5% reduction (with improved performance)
4. **Runner Scheduling**: ~5% reduction
5. **ARM Migration**: ~20% reduction on compute

## Lessons Learned

### What Worked Well
1. **Dedicated CI/CD Infrastructure**: Separating CI/CD from application workloads improved both build times and application performance
2. **Scheduled Scaling**: Simple time-based scaling provided immediate cost savings with minimal complexity
3. **ARM Migration**: Significant cost savings with minimal effort after compatibility verification
4. **Active and Passive Approach**: Reducing job queue and turnaround time
4. **Incremental Approach**: Gradual migration reduced risk and allowed for course correction

### Challenges Faced
1. **Compatibility Testing**: ARM migration required thorough testing to ensure all dependencies were compatible
2. **Balancing Cost vs. Performance**: Finding the right balance between cost optimization and maintaining performance

### Recommendations
1. **Regular Audits**: Conduct quarterly resource audits to identify unused or underutilized resources
2. **Right-Sizing**: Continuously monitor and right-size instances based on actual usage patterns
3. **Reserved Instances**: Consider Reserved Instances or Savings Plans for predictable workloads
4. **Spot Instances**: Evaluate Spot Instances for non-critical workloads to further reduce costs
5. **Monitoring**: Implement comprehensive cost monitoring and alerting to prevent cost creep

## Future Optimization Opportunities

1. **Reserved Instances/Savings Plans**: For predictable workloads, could save additional 30-40%
2. **Spot Instances**: For CI/CD runners and non-critical workloads, potential 60-90% savings
3. **Hybrid Approach**: Using current approach and using ARC for small workflloads

## Conclusion

Through a combination of resource cleanup, infrastructure optimization, CI/CD improvements, and architecture modernization, we successfully achieved a **45% reduction in monthly infrastructure costs** while improving build times and developer experience. The key to success was a systematic approach, thorough testing, and incremental implementation.

The initiatives not only reduced costs but also improved the overall infrastructure:
- Faster CI/CD pipelines
- Better resource isolation
- More scalable architecture
- Enhanced developer productivity

This experience demonstrates that significant cost savings are achievable without compromising performance or reliability when approached systematically and with careful planning.

---
