variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "  put region  "
}

variable "eks_cluster_name" {
  description = "Name of EKS cluster"
  type        = string
  default     = " put name"
}

variable "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  type        = string
  default     = " put version"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "put cidr"
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for the subnets"
  type        = list(string)
  default     = ["put subnets"]
}

variable "cluster_instance_type" {
  description = "Instance type for EKS worker nodes"
  type        = string
  default     = "put type"
}

variable "desired_capacity" {
  description = "Desired capacity of the EKS node group"
  type        = number
  default     =  put number
}

variable "max_capacity" {
  description = "Maximum capacity of the EKS node group"
  type        = number
  default     = 
}

variable "min_capacity" {
  description = "Minimum capacity of the EKS node group"
  type        = number
  default     = 
}
