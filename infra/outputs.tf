output "kubernetes_configuration" {
  value = "az aks get-credentials --resource-group ${var.tag_prefix} --name ${var.tag_prefix}"
}


output "cluster_name" {
  value = var.tag_prefix
}

output "prefix" {
  value = var.tag_prefix
}


output "pg_dbname" {
  value = "tfe"
}

output "pg_user" {
  value = var.postgres_user
}

output "pg_password" {
  value = var.postgres_password
  sensitive = true
}

output "pg_address" {
  value = azurerm_postgresql_flexible_server.example.fqdn
}

output "container_name" {
  value = azurerm_storage_container.example.name
}

output "storage_account" {
  value = azurerm_storage_account.example.name
}

output "storage_account_key" {
  value = azurerm_storage_account.example.primary_access_key
  sensitive = true
}


output "redis_host" {
  value = azurerm_redis_cache.example.hostname
}

output "redis_port" {
  value = azurerm_redis_cache.example.port
}

output "redis_primary_access_key" {
  value = azurerm_redis_cache.example.primary_access_key
  sensitive = true
}

# TFE Redis Passwordless Authentication Configuration
output "tfe_redis_passwordless_azure_client_id" {
  description = "The Client ID for TFE_REDIS_PASSWORDLESS_AZURE_CLIENT_ID"
  value       = azurerm_user_assigned_identity.tfe.client_id
}

output "tfe_redis_user" {
  description = "The Managed Identity OID for TFE_REDIS_USER"
  value       = azurerm_user_assigned_identity.tfe.principal_id
}

output "tfe_redis_managed_identity_name" {
  description = "The name of the managed identity for TFE Redis access"
  value       = azurerm_user_assigned_identity.tfe.name
}
