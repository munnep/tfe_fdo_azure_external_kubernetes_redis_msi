resource "azurerm_managed_redis" "example" {
  name                = "example-managed-redis"
  resource_group_name = azurerm_resource_group.tfe.name
  location            = azurerm_resource_group.tfe.location
  sku_name            = "Balanced_B3"

  high_availability_enabled = false

  default_database {
    access_keys_authentication_enabled = true
    client_protocol                    = "Plaintext"
    clustering_policy                  = "NoCluster" # added because redis clustering not allowed
  }
}

output "redis_managed_host" {
  value = azurerm_managed_redis.example.hostname

}

output "redis_managed_primary_access_key" {
  value     = azurerm_managed_redis.example.default_database[0].primary_access_key
  sensitive = true

}

output "redis_managed_port" {
  value     = azurerm_managed_redis.example.default_database[0].port
  sensitive = true

}


resource "azurerm_managed_redis" "sidekiq" {
  name                = "sidekiq-managed-redis"
  resource_group_name = azurerm_resource_group.tfe.name
  location            = azurerm_resource_group.tfe.location
  sku_name            = "Balanced_B3"

  high_availability_enabled = false

  default_database {
    access_keys_authentication_enabled = true
    client_protocol                    = "Plaintext"
    clustering_policy                  = "NoCluster" # added because redis clustering not allowed
  }
}

output "redis_sidekiq_managed_host" {
  value = azurerm_managed_redis.sidekiq.hostname

}

output "redis_sidekiq_managed_primary_access_key" {
  value     = azurerm_managed_redis.sidekiq.default_database[0].primary_access_key
  sensitive = true

}

output "redis_sidekiq_managed_port" {
  value     = azurerm_managed_redis.sidekiq.default_database[0].port
  sensitive = true

}
