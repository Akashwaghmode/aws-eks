output "eks_cluster_name" {
  value = module.eks_cluster.cluster_id
}

output "eks_cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "eks_node_group_id" {
  value = module.eks_cluster.node_group_id
}

// Add more outputs as needed
