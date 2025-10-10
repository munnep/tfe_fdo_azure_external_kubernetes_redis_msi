terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=5.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.22.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=2.10.1"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.5.3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.7.0"
    }
  }

  required_version = ">= 1.1"
}

provider "aws" {
  region = var.region
}


provider "acme" {
  # server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
