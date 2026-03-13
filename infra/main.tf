terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.60.0"
    }
  }

  # Remote state — Azure Storage backend
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "natesatfstatebackend"
    container_name       = "tfstate"
    key                  = "mini.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# ─────────────────────────────────────────
# Resource Group
# ─────────────────────────────────────────
resource "azurerm_resource_group" "rg" {
  name     = "rg-mini-project"
  location = "East US"
}

# ─────────────────────────────────────────
# Storage Account
# ─────────────────────────────────────────
resource "azurerm_storage_account" "sa" {
  name                     = "saminiproject"  # must be globally unique, change this
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# ─────────────────────────────────────────
# Key Vault
# ─────────────────────────────────────────
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = "kv-mini-project"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
  }
}