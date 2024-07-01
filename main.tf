// Create IAM roles for EKS 
module "eks_roles" {
  source          = "terraform-aws-modules/eks/aws//modules/iam-groups-and-roles"
  cluster_name    = var.eks_cluster_name
  // other configuration as before
}

// Create VPC for EKS (assuming previous setup)
module "eks_vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = "eks-vpc"
  cidr            = var.vpc_cidr_block
  azs             = ["${data.aws_availability_zones.available.names}"]
  private_subnets = var.subnet_cidr_blocks
  // other configuration as before
}

// Create EKS Cluster (assuming previous setup)
module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  subnets         = module.eks_vpc.private_subnets
  vpc_id          = module.eks_vpc.vpc_id
  node_group_enabled = true
  node_group_desired_capacity = var.desired_capacity
  node_group_max_capacity = var.max_capacity
  node_group_min_capacity = var.min_capacity
  node_group_instance_type = var.cluster_instance_type
  node_group_subnets = module.eks_vpc.private_subnets
  // other configuration as before
}

// Create security group for EKS control plane
resource "aws_security_group" "eks_control_plane_sg" {
  name        = "eks-control-plane-sg"
  description = "Security group for EKS control plane"
  vpc_id      = module.eks_vpc.vpc_id

  ingress {
    description = "Allow inbound traffic from worker nodes"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    // Assuming worker nodes are in a specific security group or CIDR block
    security_groups = [aws_security_group.eks_worker_nodes_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

// Create security group for EKS worker nodes
resource "aws_security_group" "eks_worker_nodes_sg" {
  name        = "eks-worker-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.eks_vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.eks_vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

// Attach security group for worker nodes to the node group
module "eks_cluster_node_group" {
  source                     = "terraform-aws-modules/eks/aws//modules/node_group"
  cluster_name               = module.eks_cluster.cluster_id
  node_group_name            = "eks-node-group"
  node_group_desired_capacity = var.desired_capacity
  node_group_max_capacity    = var.max_capacity
  node_group_min_capacity    = var.min_capacity
  node_group_instance_type   = var.cluster_instance_type
  node_group_subnet_ids      = module.eks_vpc.private_subnet_ids
  node_group_security_group_ids = [aws_security_group.eks_worker_nodes_sg.id]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

output "eks_cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  value = module.eks_cluster.cluster_security_group_id
}

output "eks_cluster_name" {
  value = module.eks_cluster.cluster_id
}

output "eks_node_group_id" {
  value = module.eks_cluster.node_group_id
}
