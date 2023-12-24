terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"      
      version = "3.85.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "py-ty-terraform"
    storage_account_name = "main"
    container_name       = "tfstate"
    key                  = "py-app.tfstate"
  }
}

provider "azurerm" {
  features {}

  subscription_id   = var.SUBSCRIPTION_ID 
  tenant_id         = var.TENANT_ID
  client_id         = var.CLIENT_ID
  client_secret     = var.CLIENT_SECRET
}