output "aks_kube_config" {
  value = module.aks.kube_config_raw
  sensitive = true

}

output "aks_host" {
  value = module.aks.host
}