data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "${path.module}/../infra/terraform.tfstate"
  }
}

data "azurerm_kubernetes_cluster" "default" {
  name                = data.terraform_remote_state.infra.outputs.cluster_name
  resource_group_name = data.terraform_remote_state.infra.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
  }
}

locals {
  namespace  = "terraform-enterprise"
  full_chain = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
}


# code idea from https://itnext.io/lets-encrypt-certs-with-terraform-f870def3ce6d
data "aws_route53_zone" "base_domain" {
  name = var.dns_zonename
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.certificate_email
}

resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.registration.account_key_pem
  common_name     = "${var.dns_hostname}.${var.dns_zonename}"

  recursive_nameservers        = ["1.1.1.1:53"]
  disable_complete_propagation = true

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.base_domain.zone_id
    }
  }

  depends_on = [acme_registration.registration]
}


data "aws_route53_zone" "selected" {
  name         = var.dns_zonename
  private_zone = false
}

resource "kubernetes_namespace" "terraform-enterprise" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_secret" "example" {
  metadata {
    name      = local.namespace
    namespace = local.namespace
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "images.releases.hashicorp.com": {
      "auth": "${base64encode("terraform:${var.tfe_license}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}


# # # The default for using the helm chart from internet
resource "helm_release" "tfe" {
  name       = local.namespace
  repository = "helm.releases.hashicorp.com"
  chart      = "hashicorp/terraform-enterprise"
  namespace  = local.namespace
  version    = "1.3.3"

  values = [
    templatefile("${path.module}/overrides.yaml", {
      replica_count = var.replica_count
      # region                   = data.terraform_remote_state.infra.outputs.region
      enc_password             = var.tfe_encryption_password
      pg_dbname                = data.terraform_remote_state.infra.outputs.pg_dbname
      pg_user                  = data.terraform_remote_state.infra.outputs.pg_user
      pg_password              = data.terraform_remote_state.infra.outputs.pg_password
      pg_address               = data.terraform_remote_state.infra.outputs.pg_address
      pg_dbname                = data.terraform_remote_state.infra.outputs.pg_dbname
      fqdn                     = "${var.dns_hostname}.${var.dns_zonename}"
      cert_data                = "${base64encode(local.full_chain)}"
      key_data                 = "${base64encode(nonsensitive(acme_certificate.certificate.private_key_pem))}"
      ca_cert_data             = "${base64encode(local.full_chain)}"
      redis_host               = data.terraform_remote_state.infra.outputs.redis_host
      redis_port               = data.terraform_remote_state.infra.outputs.redis_port
      tfe_redis_passwordless_azure_client_id = data.terraform_remote_state.infra.outputs.tfe_redis_passwordless_azure_client_id
      tfe_redis_user= data.terraform_remote_state.infra.outputs.tfe_redis_user
      storage_account_key      = data.terraform_remote_state.infra.outputs.storage_account_key
      storage_account          = data.terraform_remote_state.infra.outputs.storage_account
      container_name           = data.terraform_remote_state.infra.outputs.container_name
      tfe_license              = var.tfe_license
      tfe_release              = var.tfe_release
      load_balancer_type       = var.load_balancer_type == "external" ? "false" : "true"
      replica_count            = var.replica_count
      client_id_oidc           = data.terraform_remote_state.infra.outputs.client_id_oidc
    })
  ]
  depends_on = [
    kubernetes_secret.example, kubernetes_namespace.terraform-enterprise
  ]
}

data "kubernetes_service" "example" {
  metadata {
    name      = local.namespace
    namespace = local.namespace
  }
  depends_on = [helm_release.tfe]
}


resource "aws_route53_record" "tfe" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.dns_hostname
  type    = "A"
  ttl     = "300"
  records = [data.kubernetes_service.example.status.0.load_balancer.0.ingress.0.ip]

  depends_on = [helm_release.tfe]
}








# output "kubernetes_service" {
#   value = data.kubernetes_service.example.status.0.load_balancer.0.ingress.0.ip
# }
