# authentication uri
output "tfe_application_url" {
  value = "https://${var.dns_hostname}.${var.dns_zonename}"
}

output "execute_script_to_create_user_admin" {
  value = "./configure_tfe.sh ${var.dns_hostname}.${var.dns_zonename} patrick.munne@hashicorp.com Password#1"
}

# output "pg_password" {
#   value = data.terraform_remote_state.infra.outputs.pg_password
# }

# output "redis_primary_access_key" {
#   value = data.terraform_remote_state.infra.outputs.redis_primary_access_key
# }

# output "storage_key" {
#   value = data.terraform_remote_state.infra.outputs.storage_account_key
# }

# output "cert_data" {
#   value = base64encode(local.full_chain)
# }

# output "key_data" {
#   value = base64encode(nonsensitive(acme_certificate.certificate.private_key_pem))
# }

# output "ca_cert_data" {
#   value = base64encode(local.full_chain)
# }
