terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.69"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "tfstategarry123"
    container_name       = "tfstate"
    key                  = "governance.terraform.tfstate"
  }
}
