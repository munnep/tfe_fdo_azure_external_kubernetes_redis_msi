variable "subscription_id" {
  description = "subscription id for azure"
}

variable "dns_hostname" {
  description = "DNS hostname"
}

variable "load_balancer_type" {
  description = "Choose between an extneral or internal load balancer"
  default = "external"
}

variable "dns_zonename" {
  description = "DNS zonename"
}

variable "certificate_email" {
  description = "email address to register the certificate"
}

variable "tfe_license" {
  description = "TFE license as a string"
}

variable "tfe_encryption_password" {
  description = "TFE encryption password"
}

variable "replica_count" { 
}

variable "tfe_release" {
  description = "Which release version of TFE to install"
}

variable "region" {
  description = "region to create the environment"
}
