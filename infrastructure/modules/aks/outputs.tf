output "principal_id" {
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  description = "The Managed Identity of the AKS cluster"
}