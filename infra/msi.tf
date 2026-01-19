#------------------------------------------------------------------------------
# TFE user-assigned managed identity (MSI)
#------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "tfe" {
  name                = "${var.tag_prefix}-tfe-aks-msi"
  location            = azurerm_resource_group.tfe.location
  resource_group_name = azurerm_resource_group.tfe.name
}


# Create Redis access policy assignment for the managed identity
# resource "azurerm_redis_cache_access_policy_assignment" "tfe_redis_access" {
#   name               = "tfe-redis-access"
#   redis_cache_id     = azurerm_redis_cache.example.id
#   access_policy_name = "Data Owner"
#   object_id          = azurerm_user_assigned_identity.tfe.principal_id
#   object_id_alias    = azurerm_user_assigned_identity.tfe.principal_id
# }


# data "azurerm_subscription" "primary" {
# }


# # for the permissions for loadbalancers (using the primary TFE identity)
# resource "azurerm_role_assignment" "aks_network_contributor" {
#   scope                = data.azurerm_subscription.primary.id
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_user_assigned_identity.tfe.principal_id
# }

# Grant Managed Identity Operator role to the control plane identity for kubelet identity
resource "azurerm_role_assignment" "aks_kubelet_identity_operator" {
  scope                = azurerm_user_assigned_identity.tfe.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.tfe.principal_id
}

resource "azurerm_role_assignment" "tfe_aks_admin" {
  scope                = azurerm_kubernetes_cluster.example.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azurerm_user_assigned_identity.tfe.principal_id
}

resource "azurerm_role_assignment" "tfe_blob_storage" {

  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.tfe.principal_id
}


resource "azurerm_role_assignment" "tfe_blob_storage2" {

  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.tfe.principal_id
}


resource "azurerm_federated_identity_credential" "tfe_kube_service_account" {
  name                = "tfe-kube-service-account"
  resource_group_name =  azurerm_resource_group.tfe.name
  parent_id           = azurerm_user_assigned_identity.tfe.id
  audience            = ["api://AzureADTokenExchange"]
  
  subject             = "system:serviceaccount:terraform-enterprise:terraform-enterprise"
  issuer              = azurerm_kubernetes_cluster.example.oidc_issuer_url
}

output "azurerm_user_assigned_identity_client_id" {
    value = azurerm_user_assigned_identity.tfe.client_id
  
}

output "issues" {
  value = azurerm_kubernetes_cluster.example.oidc_issuer_url
}

output "client_id_oidc" {
  value = azurerm_user_assigned_identity.tfe.client_id
}