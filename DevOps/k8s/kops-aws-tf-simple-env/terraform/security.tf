# Security Group for Control Plane
resource "aws_security_group" "control_plane" {
  name        = "${var.project_name}-control-plane-sg"
  description = "Security group for Kubernetes control plane"
  vpc_id      = aws_vpc.k8s.id

  # SSH access (restrict to your IP in production)
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Kubernetes API server
  ingress {
    description = "Kubernetes API server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # etcd client communication
  ingress {
    description = "etcd client communication"
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    self        = true
  }

  # etcd peer communication
  ingress {
    description = "etcd peer communication"
    from_port   = 2380
    to_port     = 2380
    protocol    = "tcp"
    self        = true
  }

  # Kubelet API
  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Kube-scheduler
  ingress {
    description = "Kube-scheduler"
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    self        = true
  }

  # Kube-controller-manager
  ingress {
    description = "Kube-controller-manager"
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-control-plane-sg"
  }
}

# Security Group for Worker Nodes
resource "aws_security_group" "worker_nodes" {
  name        = "${var.project_name}-worker-node-sg"
  description = "Security group for Kubernetes worker nodes"
  vpc_id      = aws_vpc.k8s.id

  # SSH access (restrict to your IP in production)
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Kubelet API
  ingress {
    description     = "Kubelet API from control plane"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.control_plane.id]
  }

  # NodePort Services
  ingress {
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # All traffic from control plane
  ingress {
    description     = "All traffic from control plane"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.control_plane.id]
  }

  # All traffic from worker nodes (for pod-to-pod communication)
  ingress {
    description = "All traffic from worker nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-worker-node-sg"
  }
}

# KMS Key for EBS encryption
resource "aws_kms_key" "ebs" {
  count = var.enable_encryption ? 1 : 0

  description             = "KMS key for EBS volume encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow service-linked role use of the CMK"
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.control_plane.arn,
            aws_iam_role.worker_nodes.arn
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ebs-kms-key"
  }
}

resource "aws_kms_alias" "ebs" {
  count = var.enable_encryption ? 1 : 0

  name          = "alias/${var.project_name}-ebs"
  target_key_id = aws_kms_key.ebs[0].key_id
}

data "aws_caller_identity" "current" {}

